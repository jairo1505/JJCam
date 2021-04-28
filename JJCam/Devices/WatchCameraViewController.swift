//
//  WatchCameraViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 20/02/21.
//

import UIKit

class WatchCameraViewController: UIViewController {
    
    public var index = 0
    public var indexDevice = 0
    
    private var device: Device!
    private var views: [DeviceManager.DeviceView] = []
    private var maxIndex = 0
    
    var swipeRight = UISwipeGestureRecognizer()
    var swipeLeft = UISwipeGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(nextView))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)

        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(prevView))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        device = DeviceManager.shared.devices[indexDevice]
        DeviceManager.shared.getViews(deviceId: device.id ?? UUID()) { views in
            self.views = views
            self.maxIndex = views.count + (self.device.channels - 1)
            
            self.searchCameras()
        }
    }
    
    private func searchCameras() {
        if index < views.count {
            configureScreen(cameras: views[index].cameras)
        } else {
            configureScreen(cameras: [index - views.count + 1])
        }
    }
    
    @objc func prevView() {
        closeAllCameras()
        if index == 0 {
            index = maxIndex
        } else {
            index -= 1
        }
        searchCameras()
    }
    @objc func nextView() {
        closeAllCameras()
        if index == maxIndex {
            index = 0
        } else {
            index += 1
        }
        searchCameras()
    }
    
    private func configureScreen(cameras: [Int]) {
        switch cameras.count {
        case 1:
            showCameras(x: 0, y: 0, divider: 1, cameraIndex: 0, cameras: cameras)
        case 2...4:
            var linha = 0
            var coluna = 0
            for i in 1...4 {
                if linha == 2 {
                    linha = 0
                    coluna += 1
                }
                showCameras(x: CGFloat(linha), y: CGFloat(coluna), divider: 2, cameraIndex: i-1, cameras: cameras)
                linha += 1
            }
        case 5...9:
            var linha = 0
            var coluna = 0
            for i in 1...9 {
                if linha == 3 {
                    linha = 0
                    coluna += 1
                }
                showCameras(x: CGFloat(linha), y: CGFloat(coluna), divider: 3, cameraIndex: i-1, cameras: cameras)
                linha += 1
            }
        case 10...16:
            var linha = 0
            var coluna = 0
            for i in 1...16 {
                if linha == 4 {
                    linha = 0
                    coluna += 1
                }
                showCameras(x: CGFloat(linha), y: CGFloat(coluna), divider: 4, cameraIndex: i-1, cameras: cameras)
                linha += 1
            }
        default:
            let frame1 = CGRect(x: (view.frame.width/2)-500, y: (view.frame.height/2)-50, width: 1000, height: 60)
            let label1 = Utils.getLabel(title: "🤕", frame: frame1, size: 120)
            view.addSubview(label1)
            let frame2 = CGRect(x: (view.frame.width/2)-500, y: (view.frame.height/2)+50, width: 1000, height: 60)
            let label2 = Utils.getLabel(title: "Ops! Tivemos um problema.", frame: frame2, size: nil)
            view.addSubview(label2)
            UIView.animate(withDuration: 1.0) {
                label1.alpha = 1
                label2.alpha = 1
            }
        }
    }
    
    private func showCameras(x: CGFloat, y: CGFloat, divider: CGFloat, cameraIndex: Int, cameras: [Int]) {
        let xBase = view.frame.width/divider
        let yBase = view.frame.height/divider
        let cameraView = CameraView(frame: CGRect(x: x == 0 ? 0 : xBase*x, y: y == 0 ? 0 : yBase*y, width: view.frame.width/divider, height: view.frame.height/divider))
        if cameraIndex < cameras.count {
            cameraView.setUrl(url: DeviceManager.shared.devices[indexDevice].getProtocol(channel: cameras[cameraIndex], quality: cameras.count > 1 ? .low : .high))
        } else {
            cameraView.setNoVideo()
        }
        view.addSubview(cameraView)
    }
    
    private func closeAllCameras() {
        view.subviews.forEach {
            guard let view = $0 as? CameraView else { return }
            view.stop()
            view.removeFromSuperview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeAllCameras()
        view.removeGestureRecognizer(swipeLeft)
        view.removeGestureRecognizer(swipeRight)
    }

}
