//
//  DevicesTableViewController.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 15/02/21.
//

import UIKit

class DevicesTableViewController: UITableViewController {
    let deviceManager = DeviceManager.shared
    private var currentIndexFocus = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        deviceManager.get {
            self.tableView.reloadData()
        }
        let longSelectRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTouch))
        longSelectRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        self.tableView.addGestureRecognizer(longSelectRecognizer)
    }
    
    @objc func longTouch() {
        let alert = UIAlertController(title: "Dispositivo: \(deviceManager.devices[currentIndexFocus.row].name)", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remover", style: .destructive, handler: { _ in
            self.deviceManager.remove(id: self.deviceManager.devices[self.currentIndexFocus.row].id ?? 0) {
                self.tableView.deleteRows(at: [self.currentIndexFocus], with: .automatic)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceManager.devices.count == 0 ? 1 : deviceManager.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as? DeviceTableViewCell else { return UITableViewCell() }
        if deviceManager.devices.count == 0 {
            cell.title.text = "Nenhum dispositivo cadastrado!"
            cell.subtitle.text = ""
        } else {
            cell.title.text = deviceManager.devices[indexPath.row].name
            cell.subtitle.text = "\(deviceManager.devices[indexPath.row].channels) canais | \(deviceManager.devices[indexPath.row].deviceProtocol.rawValue.lowercased())"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let story = UIStoryboard(name: "Cameras", bundle: nil).instantiateInitialViewController() as? CamerasViewController else { return }
        story.index = indexPath.row
        present(story, animated: true, completion: nil)    }
    
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
