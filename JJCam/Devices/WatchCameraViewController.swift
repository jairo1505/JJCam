//
//  WatchCameraViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 20/02/21.
//

import UIKit
import TVVLCKit

class WatchCameraViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    public var indexDevice = 0
    public var indexCamera = 0
    
    private let player = VLCMediaPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cStringRef: UnsafeMutablePointer<Int8>{
        let cString = ("16:9" as NSString).utf8String
            return UnsafeMutablePointer.init(mutating: cString)!
        }
        print(DeviceManager.shared.devices[indexDevice].getProtocol(channel: indexCamera))
        player.videoAspectRatio = cStringRef
        player.drawable = cameraView
        player.media = VLCMedia(url: URL(string: DeviceManager.shared.devices[indexDevice].getProtocol(channel: indexCamera))!)
        player.play()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
    }

}
