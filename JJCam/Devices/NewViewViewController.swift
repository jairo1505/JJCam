//
//  NewViewViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 28/02/21.
//

import UIKit

protocol NewViewViewControllerDelegate: AnyObject {
    func didSaveNewView()
}

class NewViewViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var nameView: UITextField!
    @IBOutlet weak var selectorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let name = nameView.text, !(nameView.text?.isEmpty ?? true) else {
            let alert = UIAlertController(title: "Preecha o campo Nome da Visualização!", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if cameras.isEmpty {
            let alert = UIAlertController(title: "Selecione pelo menos 1 câmera", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            DeviceManager.shared.newView(name: name, deviceId: DeviceManager.shared.devices[indexDevice].id ?? UUID(), cameras: cameras)
            delegate?.didSaveNewView()
            dismiss(animated: true, completion: nil)
        }
    }
    
    private var cameras: [Int] = []
    private var limit = 4
    public var indexDevice = 0
    public var delegate: NewViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CameraTableViewCell", bundle: nil), forCellReuseIdentifier: "CameraTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        switch UIDevice.DeviceName.init(rawValue: UIDevice.modelName) {
        case .appleTv4:
            limit = 4
        case .appleTv4K:
            limit = 9
        case .appleTv4K2:
            limit = 16
        default:
            limit = 4
        }
        
        selectorLabel.text = "Selecione as câmeras na ordem desejada: (Limite máximo: \(limit))"
    }

}

extension NewViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeviceManager.shared.devices[indexDevice].channels
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CameraTableViewCell", for: indexPath) as? CameraTableViewCell else { return UITableViewCell() }
        cell.title.text = "Câmera \(indexPath.row + 1)"
        let cam = cameras.filter({$0 == indexPath.row + 1})
        cell.checkImg.alpha = cam.count > 0 ? 1 : 0
        return cell
    }
}

extension NewViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.previouslyFocusedIndexPath != nil {
            guard let oldCell = tableView.cellForRow(at: context.previouslyFocusedIndexPath!) as? CameraTableViewCell else { return }
            oldCell.title.textColor = UIColor.white
        }
        if context.nextFocusedIndexPath != nil {
            guard let newCell = tableView.cellForRow(at: context.nextFocusedIndexPath!) as? CameraTableViewCell else { return }
            newCell.title.textColor = UIColor.black
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) as? CameraTableViewCell else { return }
        for (index, item) in cameras.enumerated() {
            if item == indexPath.row + 1 {
                cameras.remove(at: index)
                cell.animateCheck(show: false)
                return
            }
        }
        if cameras.count < limit {
            cameras.append(indexPath.row + 1)
            cell.animateCheck(show: true)
        } else {
            UIView.animate(withDuration: 0.25) {
                self.selectorLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2);
            } completion: { completed in
                UIView.animate(withDuration: 0.25) {
                    self.selectorLabel.transform = CGAffineTransform(scaleX: 1, y: 1);
                }
            }
        }
    }
}
