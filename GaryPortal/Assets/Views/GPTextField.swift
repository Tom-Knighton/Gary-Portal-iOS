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


fileprivate struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.backgroundColor = UIColor.clear
        if nil != onDone {
            textField.returnKeyType = .done
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }

}

struct MultilineTextField: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 100
    @State private var showingPlaceholder = false

    init (_ placeholder: String = "", text: Binding<String>, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .background(placeholderView, alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
                    .padding(.leading, 4)
                    .padding(.top, 8)
            }
        }
    }
}
