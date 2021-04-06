//
//  NSMutableAttributedStringExtension.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 05/04/21.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    
    func append(string: String, attributes: [NSAttributedString.Key: Any]? = nil, range: NSRange? = nil) {
        if let attributes = attributes {
            if let range = range {
                append(NSAttributedString(string: string))
                addAttributes(attributes, range: range)
            } else {
                append(NSAttributedString(string: string, attributes: attributes))
            }
        } else {
            append(NSAttributedString(string: string))
        }
    }
    
    func append(attachment: NSTextAttachment) {
        append(NSAttributedString(attachment: attachment))
    }
    
    func append(image: UIImage?, bounds: CGRect) {
        let attachment = NSTextAttachment()
        attachment.image = image ?? UIImage()
        attachment.bounds = bounds
        
        append(attachment: attachment)
    }
}
