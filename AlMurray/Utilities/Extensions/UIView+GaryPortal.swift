//
//  UIView+GaryPortal.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//
import UIKit

extension UIView {
    
    func roundCorners(radius: CGFloat, masksToBounds: Bool = true) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = masksToBounds
    }
    
    func addShadow(colour: UIColor = UIColor.black, opacity: Float, offset: CGSize = .zero, radius: CGFloat) {
        self.layer.shadowColor = colour.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
    
    func addGradient(colours: [UIColor], locations: [NSNumber]?) {
        let gradient = CAGradientLayer()
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        self.layer.addSublayer(gradient)
        gradient.frame = self.layer.bounds
        gradient.sendToBack()
    }
    
    func addGradientBorder(colours: [UIColor]) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: bounds.size)
        gradient.colors = colours.map { $0.cgColor }
        
        clipsToBounds = true
        
        let shape = CAShapeLayer()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        
        shape.lineWidth = 4
        shape.path = path.cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor // clear
        gradient.mask = shape
        
        layer.insertSublayer(gradient, below: layer)
    }
    
    func endEditingWhenTappedAround() {
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapRecogniser.cancelsTouchesInView = false
        self.addGestureRecognizer(tapRecogniser)
    }

    @objc
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc
    func keyboardWillChange(_ notification: NSNotification) {
        guard let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        guard let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let deltaY = targetFrame.origin.y - curFrame.origin.y

        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY

        }, completion: { (_) in
            self.layoutIfNeeded()
        })
    }
}

extension CALayer {
    
    func addGradientLayer(colours: [UIColor], width: CGFloat = 1) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = colours.map { $0.cgColor }

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(rect: self.bounds).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer

        self.addSublayer(gradientLayer)
    }
    
    func bringToFront() {
       guard let sLayer = superlayer else {
          return
       }
       removeFromSuperlayer()
       sLayer.insertSublayer(self, at: UInt32(sLayer.sublayers?.count ?? 0))
    }

    func sendToBack() {
       guard let sLayer = superlayer else {
          return
       }
       removeFromSuperlayer()
       sLayer.insertSublayer(self, at: 0)
    }
}
