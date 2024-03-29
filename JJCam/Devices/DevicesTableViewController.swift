//
//  DevicesTableViewController.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 15/02/21.
//

import UIKit

class DevicesTableViewController: UITableViewController {
    private let deviceManager = DeviceManager.shared
    private var currentIndexFocus = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCell")
        tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceManager.get {
            self.tableView.reloadData()
        }
        let longSelectRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTouch))
        longSelectRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        self.tableView.addGestureRecognizer(longSelectRecognizer)
    }
    
    @objc func longTouch() {
        if currentIndexFocus.row != 0 {
            var index = currentIndexFocus
            let alert = UIAlertController(title: "Dispositivo: \(deviceManager.devices[index.row-1].name)", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Remover", style: .destructive, handler: { _ in
                Authentication.shared.goToAuthenticationIfNeeded(viewController: self) {
                    self.deviceManager.remove(id: self.deviceManager.devices[index.row-1].id ?? UUID()) {
                        if self.tableView.numberOfRows(inSection: 0) <= 1 {
                            self.tableView.reloadData()
                        } else {
                            index.row -= 1
                            self.tableView.deleteRows(at: [index], with: .automatic)
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Editar", style: .cancel, handler: { _ in
                guard let story = UIStoryboard(name: "NewDevice", bundle: nil).instantiateInitialViewController() as? NewDeviceViewController else { return }
                story.device = self.deviceManager.devices[index.row-1]
                Authentication.shared.goToAuthenticationIfNeeded(viewController: self, destination: story)
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceManager.devices.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as? DeviceTableViewCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            cell.title.text = "+ Adicionar dispositivo"
            cell.subtitle.text = ""
        } else {
            let attributed = NSMutableAttributedString()
            attributed.append(image: deviceManager.devices[indexPath.row-1].channels == 1 ? UIImage(systemName: "video.fill")?.withTintColor(.gray) : UIImage(systemName: "externaldrive.fill")?.withTintColor(.gray), bounds: CGRect(x: -5, y: .zero, width: 40, height: 30))
            attributed.append(string: deviceManager.devices[indexPath.row-1].name)
            cell.title.attributedText = attributed
            cell.subtitle.text = "\(deviceManager.devices[indexPath.row-1].channels == 1 ? "Câmera" : "DVR de \(deviceManager.devices[indexPath.row-1].channels) canais") | \(deviceManager.devices[indexPath.row-1].deviceProtocol.rawValue.lowercased())"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let story = UIStoryboard(name: "NewDevice", bundle: nil).instantiateInitialViewController() else { return }
            present(story, animated: true, completion: nil)
        } else {
            if deviceManager.devices[indexPath.row-1].channels == 1 {
                guard let story = UIStoryboard(name: "WatchCamera", bundle: nil).instantiateInitialViewController() as? WatchCameraViewController else { return }
                story.viewModel = WatchCameraViewController.ViewModel(flow: .camera, deviceId: deviceManager.devices[indexPath.row-1].id, viewId: nil, number: 0)
                present(story, animated: true, completion: nil)
            } else {
                guard let story = UIStoryboard(name: "Cameras", bundle: nil).instantiateInitialViewController() as? CamerasViewController else { return }
                story.index = indexPath.row-1
                present(story, animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.previouslyFocusedIndexPath != nil {
            guard let oldCell = tableView.cellForRow(at: context.previouslyFocusedIndexPath!) as? DeviceTableViewCell else { return }
            oldCell.title.textColor = UIColor.white
            oldCell.subtitle.textColor = UIColor.white
        }
        if context.nextFocusedIndexPath != nil {
            guard let newCell = tableView.cellForRow(at: context.nextFocusedIndexPath!) as? DeviceTableViewCell else { return }
            newCell.title.textColor = UIColor.black
            newCell.subtitle.textColor = UIColor.black
            currentIndexFocus = context.nextFocusedIndexPath ?? IndexPath()
        }
    }
}
