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
    
    public var index: Int = 0
    private let deviceManager = DeviceManager.shared
    private var currentIndexFocus = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CameraTableViewCell", bundle: nil), forCellReuseIdentifier: "CameraTableViewCell")
        navigationBar.topItem?.title = deviceManager.devices[index].name
    }    
}

// MARK: - Table view data source
extension CamerasViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceManager.devices[index].channels
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CameraTableViewCell", for: indexPath) as? CameraTableViewCell else { return UITableViewCell() }
            cell.title.text = "Câmera \(indexPath.row + 1)"
        return cell
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
        story.viewModel = WatchCameraViewController.ViewModel(flow: .camera, deviceId: deviceManager.devices[index].id, viewId: nil, number: indexPath.row)
        present(story, animated: true, completion: nil)
    }
}
