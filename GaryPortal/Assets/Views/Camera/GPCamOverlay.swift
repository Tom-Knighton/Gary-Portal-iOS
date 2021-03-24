//
//  GPCam+Text.swift
//  GaryPortal
//
//  Created by Tom Knighton on 22/03/2021.
//

import Foundation
import SwiftUI

protocol CamTextViewDelegate {
    func addedSubview()
    func removedSubview()
    func updateImage(image: UIImage)
}

struct CamTextViewRepresentable: UIViewRepresentable {
    
    @Binding var subviewCount: Int
    @Binding var overlayViewImage: UIImage
    
    func makeUIView(context: Context) -> CamTextView {
        let camTextView = CamTextView()
        camTextView.delegate = context.coordinator
        return camTextView
    }
    
    func updateUIView(_ uiView: CamTextView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    final class Coordinator: NSObject, CamTextViewDelegate {
        
        var parent: CamTextViewRepresentable
        
        init(_ parent: CamTextViewRepresentable) {
            self.parent = parent
        }
        
        func addedSubview() {
            self.parent.subviewCount += 1
        }
        
        func removedSubview() {
            self.parent.subviewCount = max(0, self.parent.subviewCount - 1)
        }
        
        func updateImage(image: UIImage) {
            self.parent.overlayViewImage = image
        }
    }
}

class CamTextView: UIView {
    
    private var lastPanPoint: CGPoint?
    private var lastTextViewTransform: CGAffineTransform?
    private var lastTextViewCenter: CGPoint?
    
    private var deleteButton: UIImageView?
    
    var delegate: CamTextViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bindFrameToSuperviewBounds()
        NotificationCenter.default.addObserver(self, selector: #selector(addTextBtn(_:)), name: .addTextLabelPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addStickerBtn(_:)), name: .addStickerLabelPressed, object: nil)
        self.hideKeyboardWhenTappedAround()
        
        self.deleteButton = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.deleteButton?.isHidden = true
        self.addSubview(deleteButton ?? UIImageView())
        self.deleteButton?.image = UIImage(systemName: "trash.circle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        self.deleteButton?.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.deleteButton?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.deleteButton?.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        self.deleteButton?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .addTextLabelPressed, object: nil)
        NotificationCenter.default.removeObserver(self, name: .addStickerLabelPressed, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc
    func addTextBtn(_ sender: Notification) {
        let textView = GPCamTextView(frame: CGRect(x: self.center.x, y: self.center.y, width: 20, height: 30), textContainer: nil)
        textView.delegate = self
        self.addSubview(textView)
        self.addGestures(view: textView)
        textView.becomeFirstResponder()
        self.delegate?.addedSubview()
        self.delegate?.updateImage(image: self.asImage())
    }
    
    @objc
    func addStickerBtn(_ sender: Notification) {
        let stickerView = UIImageView(image: UIImage(named: "beaver"))
        stickerView.frame.size = CGSize(width: 75, height: 75)
        stickerView.contentMode = .scaleAspectFit
        stickerView.center = self.center
        self.addSubview(stickerView)
        self.addGestures(view: stickerView)
        self.delegate?.addedSubview()
        self.delegate?.updateImage(image: self.asImage())
    }
    
    func addGestures(view: UIView) {
        view.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGesture(_:)))
        rotationGesture.delegate = self
        view.addGestureRecognizer(rotationGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func panGesture(_ recogniser: UIPanGestureRecognizer) {
        if let view = recogniser.view {
            moveView(view: view, recogniser: recogniser)
        }
    }
    
    @objc
    func pinchGesture(_ recogniser: UIPinchGestureRecognizer) {
        guard let view = recogniser.view else { return }
        
        if view is GPCamTextView, let textView = view as? GPCamTextView {
            if textView.font!.pointSize * recogniser.scale < 90 {
                let font = UIFont(name: "Helvetica", size: textView.font!.pointSize * recogniser.scale)
                textView.font = font
                let width = min(textView.intrinsicContentSize.width, UIScreen.main.bounds.width)
                let sizeToFit = textView.sizeThatFits(CGSize(width: width, height:CGFloat.greatestFiniteMagnitude))
                textView.bounds.size = CGSize(width: sizeToFit.width, height: sizeToFit.height)
            } else {
                let width = min(textView.intrinsicContentSize.width, UIScreen.main.bounds.width)
                let sizeToFit = textView.sizeThatFits(CGSize(width: width, height:CGFloat.greatestFiniteMagnitude))
                textView.bounds.size = CGSize(width: sizeToFit.width, height: sizeToFit.height)
            }
            
            textView.setNeedsDisplay()
        } else {
            view.transform = view.transform.scaledBy(x: recogniser.scale, y: recogniser.scale)
        }
        recogniser.scale = 1
        
        if recogniser.state == .ended {
            self.delegate?.updateImage(image: self.asImage())
        }
    }
    
    @objc
    func rotationGesture(_ recogniser: UIRotationGestureRecognizer) {
        guard let view = recogniser.view, !(view is GPCamTextView) else { return }

        view.transform = view.transform.rotated(by: recogniser.rotation)
        recogniser.rotation = 0
        
        if recogniser.state == .ended {
            self.delegate?.updateImage(image: self.asImage())
        }
    }
    
    @objc
    func tapGesture(_ recogniser: UITapGestureRecognizer) {
        guard let view = recogniser.view else { return }
        
        view.superview?.bringSubviewToFront(view)
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let oldTransform = view.transform
        UIView.animate(withDuration: 0.2) {
            view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        } completion: { (_) in
            UIView.animate(withDuration: 0.2) {
                view.transform = oldTransform
            }
        }
        self.delegate?.updateImage(image: self.asImage())
    }
    
    func moveView(view: UIView, recogniser: UIPanGestureRecognizer) {
        view.superview?.bringSubviewToFront(view)
        self.deleteButton?.isHidden = false
        
        let pointToSuperView = recogniser.location(in: self)
        view.center = CGPoint(x: view.center.x + recogniser.translation(in: self).x, y: view.center.y + recogniser.translation(in: self).y)
        recogniser.setTranslation(.zero, in: self)
        
        
        if let previousPoint = lastPanPoint {
            // View is going into delete button
            if deleteButton?.frame.contains(pointToSuperView) == true && deleteButton?.frame.contains(previousPoint) == false {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                UIView.animate(withDuration: 0.3) {
                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
                    view.center = recogniser.location(in: self)
                    
                    self.deleteButton?.transform = self.deleteButton?.transform.scaledBy(x: 2, y: 2) ?? .identity
                }
            } else if deleteButton?.frame.contains(previousPoint) == true && deleteButton?.frame.contains(pointToSuperView) == false {
                // View is going out of delete button
                UIView.animate(withDuration: 0.3) {
                    view.transform = view.transform.scaledBy(x: 4, y: 4)
                    view.center = recogniser.location(in: self)
                    self.deleteButton?.transform = self.deleteButton?.transform.scaledBy(x: 0.5, y: 0.5) ?? .identity
                }
            }
        }
        self.lastPanPoint = pointToSuperView
        
        
        
        if recogniser.state == .ended {
            lastPanPoint = nil
            self.deleteButton?.isHidden = true
            let point = recogniser.location(in: self)
            if deleteButton?.frame.contains(point) == true {
                view.removeFromSuperview()
                self.delegate?.removedSubview()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.deleteButton?.transform = self.deleteButton?.transform.scaledBy(x: 0.5, y: 0.5) ?? .identity
            } else if !self.bounds.contains(view.center) {
                UIView.animate(withDuration: 0.3) {
                    view.center = self.center
                }
            }
            self.delegate?.updateImage(image: self.asImage())
        }
    }
}

extension CamTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            let width = min(textView.intrinsicContentSize.width, UIScreen.main.bounds.width)
            let sizeToFit = textView.sizeThatFits(CGSize(width: width, height:CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: sizeToFit.width, height: sizeToFit.height)
        }
        self.delegate?.updateImage(image: self.asImage())
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.lastTextViewTransform = textView.transform
        self.lastTextViewCenter = textView.center
        textView.superview?.bringSubviewToFront(textView)
        UIView.animate(withDuration: 0.3) {
            textView.transform  = CGAffineTransform.identity
            textView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        }
        self.delegate?.updateImage(image: self.asImage())
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let lastTransform = lastTextViewTransform, let lastCenter = lastTextViewCenter else {
            textView.center = self.center
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            textView.transform = lastTransform
            textView.center = lastCenter
        }
        
        if textView.text.trim().count == 0 {
            textView.removeFromSuperview()
            self.delegate?.removedSubview()
        }
        self.delegate?.updateImage(image: self.asImage())
    }
}

extension CamTextView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
