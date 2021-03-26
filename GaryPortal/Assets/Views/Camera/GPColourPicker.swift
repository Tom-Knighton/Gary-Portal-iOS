//
//  ColourPicker.swift
//  GaryPortal
//
//  Created by Tom Knighton on 22/03/2021.
//

import Foundation
import SwiftUI
import UIKit

protocol GPColourPickerDelegate {
    func changedColour(to colour: UIColor)
}

class GPColourPicker: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, delegate: GPColourPickerDelegate) {
        self.init(frame: frame)
        let host = UIHostingController(rootView: ColoursView(delegate: delegate))
        host.view.backgroundColor = .clear
        self.addSubview(host.view)
        host.view.bindFrameToSuperviewBounds()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}

fileprivate struct ColoursView: View {
    var colours: [UIColor] = [ #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.3803921569, green: 0.3803921569, blue: 0.3803921569, alpha: 1), #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1), #colorLiteral(red: 1, green: 0.5411764706, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 1, green: 0.09019607843, blue: 0.2666666667, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.7254901961, green: 0.9647058824, blue: 0.7921568627, alpha: 1), #colorLiteral(red: 0, green: 0.9019607843, blue: 0.462745098, alpha: 1), #colorLiteral(red: 0, green: 0.7843137255, blue: 0.3254901961, alpha: 1), #colorLiteral(red: 0.9176470588, green: 0.5019607843, blue: 0.9882352941, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0, blue: 0.9764705882, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0.5529411765, alpha: 1), #colorLiteral(red: 1, green: 0.9176470588, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8392156863, blue: 0, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.5333333333, blue: 1, alpha: 1), #colorLiteral(red: 0.3960784314, green: 0.1215686275, blue: 1, alpha: 1), #colorLiteral(red: 0.3843137255, green: 0, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 1, green: 0.8196078431, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 1, green: 0.568627451, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4274509804, blue: 0, alpha: 1), #colorLiteral(red: 0.5490196078, green: 0.6196078431, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 1, green: 0.6196078431, blue: 0.5019607843, alpha: 1), #colorLiteral(red: 1, green: 0.2392156863, blue: 0, alpha: 1), #colorLiteral(red: 0.8666666667, green: 0.1725490196, blue: 0, alpha: 1), #colorLiteral(red: 0.5019607843, green: 0.8470588235, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0.737254902, green: 0.6666666667, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 0.4745098039, green: 0.3333333333, blue: 0.2823529412, alpha: 1), #colorLiteral(red: 0.3058823529, green: 0.2039215686, blue: 0.1803921569, alpha: 1), #colorLiteral(red: 0.5176470588, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.8980392157, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.7215686275, blue: 0.831372549, alpha: 1)]
    
    var delegate: GPColourPickerDelegate?
    @State var chosenColour: UIColor?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView(.horizontal) {
                    HStack {
                        Spacer()
                        ForEach(colours, id: \.self) { colour in
                            HStack {
                                Spacer().frame(width: 8)
                                Circle()
                                    .fill(Color(colour.cgColor))
                                    .if(self.chosenColour == colour) {
                                        $0.overlay(Circle().stroke(Color.white))
                                    }
                                    .shadow(radius: self.chosenColour == colour ? 5 : 0)
                                    .frame(width: geometry.size.height - 10, height: geometry.size.height - 10)

                                Spacer().frame(width: 8)
                            }
                            .onTapGesture {
                                self.chosenColour = colour
                                delegate?.changedColour(to: colour)
                            }
                        }
                        Spacer()
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 40)
            }
        }
    }
}
