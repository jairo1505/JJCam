//
//  WatchCameraViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 20/02/21.
//

import UIKit

class WatchCameraViewController: UIViewController {
    
    public var indexDevice = 0
    public var indexCamera = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraView = CameraView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        cameraView.setUrl(url: DeviceManager.shared.devices[indexDevice].getProtocol(channel: indexCamera))
        view.addSubview(cameraView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.subviews.forEach {
            guard let view = $0 as? CameraView else { return }
            view.stop()
            view.removeFromSuperview()
        }
    }

}
