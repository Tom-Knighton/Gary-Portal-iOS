//
//  GPTextField.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI
import Combine

struct GPTextField: View {
    @State private var oldText = ""
    @Binding var text: String
    @State var isSystemImage = false
    @State var imageName = ""
    @State var isSecure = false
    @State var placeHolder = ""
    @State var textContentType: UITextContentType?
    @State var characterLimit: Int?
    @State var characterSet: String?
    
    var body: some View {
        HStack {
            if imageName != "" {
                if isSystemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                } else {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
            }
            
            if isSecure {
                SecureField(placeHolder, text: $text)
                    .textContentType(textContentType)
                    .keyboardType(getKeyboardType())
                    .onReceive(Just(self.text), perform: { inputValue in
                        var isValid = true
                        if let chars = self.characterSet, !filtered(range: chars, text: inputValue) {
                            isValid = false
                            self.text = oldText
                        }
                        
                        if let limit = self.characterLimit, limit > 0, inputValue.count > limit {
                            isValid = false
                            self.text = oldText
                        }
                        
                        if isValid {
                            self.oldText = inputValue
                        }
                    })
            } else {
                TextField(placeHolder, text: $text)
                    .textContentType(textContentType)
                    .keyboardType(getKeyboardType())
                    .onReceive(Just(self.text), perform: { inputValue in
                        var isValid = true
                        if let chars = self.characterSet, !filtered(range: chars, text: inputValue) {
                            isValid = false
                            self.text = oldText
                        }
                        
                        if let limit = self.characterLimit, limit > 0, inputValue.count > limit {
                            isValid = false
                            self.text = oldText
                        }
                        
                        if isValid {
                            self.oldText = inputValue
                        }
                    })
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.clear)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 10)
        )
    }
    
    func filtered(range: String, text: String) -> Bool {
        let charset = NSCharacterSet(charactersIn: range).inverted
        let filtered = text.components(separatedBy: charset).joined(separator: "")
        return text == filtered
    }
    
    func getKeyboardType() -> UIKeyboardType {
        if let contentType = self.textContentType {
            switch contentType {
            case .URL:
                return .URL
            case .addressCity, .addressState, .addressCityAndState, .fullStreetAddress, .streetAddressLine1, .streetAddressLine2:
                return .default
            case .countryName:
                return .default
            case .creditCardNumber:
                return .numberPad
            case .emailAddress:
                return .emailAddress
            case .familyName, .givenName, .name, .namePrefix, .nameSuffix, .middleName, .organizationName, .nickname, .username:
                return .default
            case .newPassword:
                return .default
            case .oneTimeCode:
                return .numberPad
            case .telephoneNumber:
                return .numberPad
            default:
                return .default
            }
        }
        return .default
    }
}

struct GPNumberField: View {
    
    @Binding var value: String
    @State var isSystemImage = false
    @State var imageName = ""
    @State var placeHolder = ""
    
    var body: some View {
        HStack {
            if imageName != "" {
                if isSystemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                } else {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
            }
            TextField("", text: $value)
                .textContentType(UITextContentType.oneTimeCode)
                .keyboardType(UIKeyboardType.numberPad)
                .onReceive(Just(value), perform: { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        self.value = filtered
                    }
                })
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.clear)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 10)
        )
    }
}
