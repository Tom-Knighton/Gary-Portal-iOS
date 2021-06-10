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
    @State var autoCapitalisation: UITextAutocapitalizationType = .words
    @State var disableCorrection = false
    
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
                    .autocapitalization(self.autoCapitalisation)
                    .disableAutocorrection(self.disableCorrection)
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
                    .autocapitalization(self.autoCapitalisation)
                    .disableAutocorrection(self.disableCorrection)
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


struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var isEditable: Bool = true
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = isEditable
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.backgroundColor = UIColor.clear
        textField.dataDetectorTypes = .all
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
        uiView.isEditable = isEditable
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

private let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

struct LinkColoredText: View {
    enum Component {
        case text(String)
        case link(String, URL)
    }

    let text: String
    let components: [Component]

    init(text: String, links: [NSTextCheckingResult]) {
        self.text = text
        let nsText = text as NSString

        var components: [Component] = []
        var index = 0
        for result in links {
            if result.range.location > index {
                components.append(.text(nsText.substring(with: NSRange(location: index, length: result.range.location - index))))
            }
            components.append(.link(nsText.substring(with: result.range), result.url!))
            index = result.range.location + result.range.length
        }

        if index < nsText.length {
            components.append(.text(nsText.substring(from: index)))
        }

        self.components = components
    }

    var body: some View {
        components.map { component in
            switch component {
            case .text(let text):
                return Text(verbatim: text)
            case .link(let text, _):
                return Text(verbatim: text)
                    .foregroundColor(.accentColor)
            }
        }.reduce(Text(""), +)
    }
}

struct LinkedText: View {
    let text: String
    let links: [NSTextCheckingResult]
    
    init (_ text: String) {
        self.text = text
        let nsText = text as NSString

        // find the ranges of the string that have URLs
        let wholeString = NSRange(location: 0, length: nsText.length)
        links = linkDetector.matches(in: text, options: [], range: wholeString)
    }
    
    var body: some View {
        LinkColoredText(text: text, links: links)
            .font(.body) // enforce here because the link tapping won't be right if it's different
            .overlay(LinkTapOverlay(text: text, links: links))
    }
}

private struct LinkTapOverlay: UIViewRepresentable {
    let text: String
    let links: [NSTextCheckingResult]
    
    func makeUIView(context: Context) -> LinkTapOverlayView {
        let view = LinkTapOverlayView()
        view.textContainer = context.coordinator.textContainer
        
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapLabel(_:)))
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: LinkTapOverlayView, context: Context) {
        let attributedString = NSAttributedString(string: text, attributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
        context.coordinator.textStorage = NSTextStorage(attributedString: attributedString)
        context.coordinator.textStorage!.addLayoutManager(context.coordinator.layoutManager)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let overlay: LinkTapOverlay

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        var textStorage: NSTextStorage?
        
        init(_ overlay: LinkTapOverlay) {
            self.overlay = overlay
            
            textContainer.lineFragmentPadding = 0
            textContainer.lineBreakMode = .byWordWrapping
            textContainer.maximumNumberOfLines = 0
            layoutManager.addTextContainer(textContainer)
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            let location = touch.location(in: gestureRecognizer.view!)
            let result = link(at: location)
            return result != nil
        }
        
        @objc func didTapLabel(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view!)
            guard let result = link(at: location) else {
                return
            }

            guard let url = result.url else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        private func link(at point: CGPoint) -> NSTextCheckingResult? {
            guard !overlay.links.isEmpty else {
                return nil
            }

            let indexOfCharacter = layoutManager.characterIndex(
                for: point,
                in: textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )

            return overlay.links.first { $0.range.contains(indexOfCharacter) }
        }
    }
}

private class LinkTapOverlayView: UIView {
    var textContainer: NSTextContainer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        var newSize = bounds.size
        newSize.height += 20 // need some extra space here to actually get the last line
        textContainer.size = newSize
    }
}
