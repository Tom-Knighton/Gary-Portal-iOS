//
//  GPGradientButton.swift
//  GaryPortal
//
//  Created by Tom Knighton on 15/01/2021.
//

import SwiftUI

struct GPGradientButton: View {
    
    private var buttonText: Text
    private var gradientColors: [Color] = [.blue, .blue]
    
    private let action: () -> ()
    
    init(action: @escaping () -> (), buttonText: String = "", gradientColours: [Color] = []) {
        self.action = action
        self.buttonText = Text(buttonText)
        self.gradientColors = gradientColours
    }
    
    init(action: @escaping () -> (), buttonText: Text, gradientColours: [Color] = []) {
        self.action = action
        self.buttonText = buttonText
        self.gradientColors = gradientColours
    }
        
    var body: some View {
        Button(action: action, label: {
            buttonText
                .font(Font.custom("Montserrat-Regular", size: 17))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(15)
        })
        .padding(.leading)
        .padding(.trailing)
        .shadow(radius: 3)
    }
}
