//
//  View+GaryPortal.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import Foundation
import SwiftUI
import Combine
import UIKit

extension UIView {
    func bindFrameToSuperviewBounds(percentageMultiplier: CGFloat = 1) {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: 0).isActive = true
        self.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: percentageMultiplier).isActive = true
    }
}

class AnyGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touchedView = touches.first?.view, touchedView is UIControl {
            state = .cancelled
            
        } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
            state = .cancelled
            
        } else {
            state = .began
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
    
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        let kAppearAction = "appear_action"
        let queue = OperationQueue.main
        let delayOperation = BlockOperation {
            Thread.sleep(forTimeInterval: 0.001)
        }
        let appearOperation = BlockOperation {
            perform()
        }
        appearOperation.name = kAppearAction
        appearOperation.addDependency(delayOperation)
        return onAppear {
            if !delayOperation.isFinished, !delayOperation.isExecuting {
                queue.addOperation(delayOperation)
            }
            if !appearOperation.isFinished, !appearOperation.isExecuting {
                queue.addOperation(appearOperation)
            }
        }
        .onDisappear {
            queue.operations
                .first { $0.name == kAppearAction }?
                .cancel()
        }
    }
    
    func badge(count: Int = 0) -> some View {
        ZStack(alignment: .topTrailing) {
            self
            ZStack {
                let countStr = count > 99 ? "99+" : "\(count)"
                if count != 0 {
                    Text(countStr)
                        .foregroundColor(.white)
                        .font(.footnote)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.red))
                        .animation(nil)
                        .transition(.scale)
                }
            }
            .offset(x: 12, y: -12)
            .shadow(color: Color.black.opacity(0.5), radius: 3)
        }
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

//public struct ListSeparatorStyleNoneModifier: ViewModifier {
//    public func body(content: Content) -> some View {
//        content.onAppear {
//            UITableView.appearance().separatorStyle = .none
//        }.onDisappear {
//            UITableView.appearance().separatorStyle = .singleLine
//        }
//    }
//}
