//
//  CameraTableViewCell.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 20/02/21.
//

import UIKit

class CameraTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var checkImg: UIImageView!
    
    public func animateCheck(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.5) {
                self.checkImg.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.checkImg.alpha = 0
            }
        }
    }
}
