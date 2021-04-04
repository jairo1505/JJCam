//
//  CircularProgressView.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 04/04/21.
//

import UIKit

protocol CircularProgressViewDelegate {
    func didFinishAnimation()
}

class CircularProgressView: UIView {
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var label = UILabel()
    public var delegate: CircularProgressViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
        
    func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: center.x, y: center.y), radius: 180, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 2.0
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.green.cgColor
        label.textAlignment = .center
        label.alpha = 0
        label.font = UIFont.systemFont(ofSize: 40)
        label.frame = CGRect(x: center.x - 80, y: center.y - 20, width: 160, height: 40)
        layer.addSublayer(circleLayer)
        layer.addSublayer(progressLayer)
        layer.addSublayer(label.layer)
    }
    
    func reloadPosition() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: center.x, y: center.y), radius: 180, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true)
        circleLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
        label.frame = CGRect(x: center.x - 80, y: center.y - 20, width: 160, height: 40)
    }
    
    func setText(_ text: String) {
        label.text = text
    }
    
    func progressAnimation(duration: TimeInterval) {
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        circularProgressAnimation.delegate = self
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
}

extension CircularProgressView: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        UIView.animate(withDuration: 0.5) {
            self.label.alpha = 1
        }
        progressLayer.strokeColor = UIColor.green.cgColor
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { _ in
            self.progressLayer.strokeColor = UIColor.red.cgColor
        }
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.label.alpha = 0
        }
        delegate?.didFinishAnimation()
    }
}
