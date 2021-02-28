//
//  CameraView.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 28/02/21.
//

import UIKit
import TVVLCKit

class CameraView: UIView {

    private let player = VLCMediaPlayer()
    private var indicator: UIActivityIndicatorView!
    
    open func setUrl(url: String?) {
        guard let url = url else { return }
        var cStringRef: UnsafeMutablePointer<Int8>{
        let cString = ("16:9" as NSString).utf8String
            return UnsafeMutablePointer.init(mutating: cString)!
        }
        
        indicator = showIndicatorView(camView: self)
        
        player.videoAspectRatio = cStringRef
        player.media = VLCMedia(url: URL(string: url)!)
        player.delegate = self
        player.drawable = self
        player.play()
    }
    
    open func stop() {
        player.stop()
    }
    
    private func getLabel(title: String, frame: CGRect, isHidden: Bool? = true, size: CGFloat?) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = title
        if let size = size {
            label.font = UIFont.systemFont(ofSize: size)
        }
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.alpha = (isHidden ?? true) ? 0 : 1
        return label
    }
    
    private func showIndicatorView(camView: UIView) -> UIActivityIndicatorView {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: (camView.frame.width/2)-25, y: (camView.frame.height/2)-25, width: 50, height: 50))
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        camView.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        return loadingIndicator
    }
}

extension CameraView: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer, let camView = player.drawable as? UIView else { return }
        switch player.state {
        case .error, .stopped:
            let frame1 = CGRect(x: (camView.frame.width/2)-500, y: (camView.frame.height/2)-50, width: 1000, height: 60)
            let label1 = getLabel(title: "🤕", frame: frame1, size: 120)
            self.addSubview(label1)
            let frame2 = CGRect(x: (camView.frame.width/2)-500, y: (camView.frame.height/2)+50, width: 1000, height: 60)
            let label2 = getLabel(title: "Ops! Tivemos um problema.", frame: frame2, size: nil)
            self.addSubview(label2)
            UIView.animate(withDuration: 1.0, animations: {
                self.indicator.alpha = 0
            }) { finish in
                if finish {
                    self.indicator.stopAnimating()
                    self.willRemoveSubview(self.indicator)
                    UIView.animate(withDuration: 1.0) {
                        label1.alpha = 1
                        label2.alpha = 1
                    }
                }
            }
        default:
            break
        }
    }

}
