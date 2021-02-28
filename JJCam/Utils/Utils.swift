//
//  Utils.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 28/02/21.
//

import UIKit

class Utils {
    static func getLabel(title: String, frame: CGRect, isHidden: Bool? = true, size: CGFloat?) -> UILabel {
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
}
