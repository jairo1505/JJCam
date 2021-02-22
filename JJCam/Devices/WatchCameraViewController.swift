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
    private let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        indicator.center = view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(cameraView)
        indicator.startAnimating()
        
        var cStringRef: UnsafeMutablePointer<Int8>{
        let cString = ("16:9" as NSString).utf8String
            return UnsafeMutablePointer.init(mutating: cString)!
        }
        player.delegate = self
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

extension WatchCameraViewController: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if player.state == .stopped || player.state == .error
        {
            let label1 = UILabel(frame: CGRect(x: cameraView.frame.width/2-500, y: cameraView.frame.height/2-50, width: 1000, height: 60))
            label1.text = "🤕"
            label1.font = UIFont.systemFont(ofSize: CGFloat(120))
            label1.textAlignment = .center
            label1.textColor = UIColor.white
            label1.alpha = 0
            cameraView.addSubview(label1)
            let label2 = UILabel(frame: CGRect(x: cameraView.frame.width/2-500, y: cameraView.frame.height/2+50, width: 1000, height: 60))
            label2.text = "Ops! Tivemos um problema."
            label2.textAlignment = .center
            label2.textColor = UIColor.white
            label2.alpha = 0
            cameraView.addSubview(label2)
            UIView.animate(withDuration: 0.5, animations: {
                self.indicator.alpha = 0
            }) { finish in
                if finish {
                    self.indicator.stopAnimating()
                    self.view.willRemoveSubview(self.indicator)
                    UIView.animate(withDuration: 0.5) {
                        label1.alpha = 1
                        label2.alpha = 1
                    }
                }
            }
        }
    }
    
    func mediaPlayerSnapshot(_ aNotification: Notification!) {
        print("AQUI!!!!!!!")
    }
}
