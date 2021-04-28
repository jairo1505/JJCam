//
//  CamerasTableViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 20/02/21.
//

import UIKit

class CamerasViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func newView(_ sender: UIBarButtonItem) {
        guard let story = UIStoryboard(name: "NewView", bundle: nil).instantiateInitialViewController() as? NewViewViewController else { return }
        story.indexDevice = index
        story.delegate = self
        present(story, animated: true, completion: nil)
    }
    
    public var index: Int = 0
    private let deviceManager = DeviceManager.shared
    private var views: [DeviceManager.DeviceView] = []
    private var currentIndexFocus = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CameraTableViewCell", bundle: nil), forCellReuseIdentifier: "CameraTableViewCell")
        navigationBar.topItem?.title = deviceManager.devices[index].name
        reloadViews()
        
        let longSelectRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTouch))
        longSelectRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        self.tableView.addGestureRecognizer(longSelectRecognizer)
    }
    
    private func reloadViews() {
        deviceManager.getViews(deviceId: deviceManager.devices[index].id ?? UUID()) { views in
            self.views = views
            self.tableView.reloadData()
        }
    }
    
    @objc func longTouch() {
        if currentIndexFocus.section == 0 {
            let alert = UIAlertController(title: "Visualização: \(views[currentIndexFocus.row].name)", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Remover", style: .destructive, handler: { _ in
                self.deviceManager.removeView(id: self.views[self.currentIndexFocus.row].id) {
                    self.views.remove(at: self.currentIndexFocus.row)
                    self.tableView.deleteRows(at: [self.currentIndexFocus], with: .automatic)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Table view data source
extension CamerasViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return views.count
        } else {
            return deviceManager.devices[index].channels
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CameraTableViewCell", for: indexPath) as? CameraTableViewCell else { return UITableViewCell() }
        if indexPath.section == 0 {
            cell.title.text = "\(views[indexPath.row].name)"
        } else {
            cell.title.text = "Câmera \(indexPath.row + 1)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if views.count != 0 {
                return "Visualizações"
            } else {
                return ""
            }
        } else {
            return "Cameras"
        }
    }
}

// MARK: - Table view delegate
extension CamerasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.previouslyFocusedIndexPath != nil {
            guard let oldCell = tableView.cellForRow(at: context.previouslyFocusedIndexPath!) as? CameraTableViewCell else { return }
            oldCell.title.textColor = UIColor.white
        }
        if context.nextFocusedIndexPath != nil {
            guard let newCell = tableView.cellForRow(at: context.nextFocusedIndexPath!) as? CameraTableViewCell else { return }
            newCell.title.textColor = UIColor.black
            currentIndexFocus = context.nextFocusedIndexPath ?? IndexPath()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let story = UIStoryboard(name: "WatchCamera", bundle: nil).instantiateInitialViewController() as? WatchCameraViewController else { return }
        story.indexDevice = index
        story.index = indexPath.section == 0 ? indexPath.row : indexPath.row + views.count
        present(story, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension CamerasViewController: NewViewViewControllerDelegate {
    func didSaveNewView() {
        reloadViews()
    }
}
