//
//  ViewsTableViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 25/06/21.
//

import UIKit

class ViewsTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var currentIndexFocus = IndexPath()
    
    private let deviceManager = DeviceManager.shared
    
    private var views: [DeviceManager.DeviceView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DeviceTableViewCell", bundle: nil), forCellReuseIdentifier: "DeviceTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        
        let longSelectRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTouch))
        longSelectRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        self.tableView.addGestureRecognizer(longSelectRecognizer)
        
        deviceManager.get {
            self.reloadViews()
        }
    }
    
    private func reloadViews() {
        deviceManager.getViews { [self] data in
            views = data
            tableView.reloadData()
        }
    }
    
    @objc func longTouch() {
        if currentIndexFocus.section == 0 {
            let index = currentIndexFocus.row-1
            let alert = UIAlertController(title: "Visualização: \(views[index].name)", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Remover", style: .destructive, handler: { [self] _ in
                deviceManager.removeView(id: views[index].id) {
                    views.remove(at: index)
                    tableView.reloadSections([0], with: .automatic)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewsTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return views.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as? DeviceTableViewCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            cell.title.text = "+ Adicionar visualização"
            cell.subtitle.text = ""
        } else {
            let numberOfCameras = views[indexPath.row-1].cameras.count
            cell.title.text = views[indexPath.row-1].name
            cell.subtitle.text = "\(numberOfCameras) câmera\(numberOfCameras <= 1 ? "" : "s")"
        }
        return cell
    }
}

extension ViewsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let story = UIStoryboard(name: "NewView", bundle: nil).instantiateInitialViewController() as? NewViewViewController else { return }
            story.delegate = self
            present(story, animated: true, completion: nil)
        } else {
            guard let story = UIStoryboard(name: "WatchCamera", bundle: nil).instantiateInitialViewController() as? WatchCameraViewController else { return }
            story.viewModel = WatchCameraViewController.ViewModel(flow: .view, deviceId: nil, viewId: views[indexPath.row-1].id, number: indexPath.row-1)
            present(story, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
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

extension ViewsTableViewController: NewViewViewControllerDelegate {
    func didSaveNewView() {
        reloadViews()
    }
}
