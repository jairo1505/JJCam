//
//  UIViewExtension.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 03/02/21.
//

import UIKit

extension UIView {
    class func delay(seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
}
