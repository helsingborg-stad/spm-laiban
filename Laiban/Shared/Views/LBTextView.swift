//
//  TextView.swift
//
//  Created by Tomas Green on 2020-05-13.
//

import SwiftUI
import Combine

public struct LBTextView: View {
    @State private var firstResponder:Bool = false
    @State private var textViewHeight:CGFloat = 20
    var placeholder:String
    var autocapitalizationType:UITextAutocapitalizationType = .sentences
    @Binding var text:String
    public init(_ placeholder:String,text:Binding<String>,autocapitalizationType:UITextAutocapitalizationType = .sentences) {
        self.placeholder = placeholder
        self.autocapitalizationType = autocapitalizationType
        self._text = text
    }
    public var body: some View {
        ZStack() {
            if firstResponder == false && text.isEmpty {
                Text(self.placeholder).frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .topLeading).foregroundColor(Color.gray)
            }
            LBTextViewEditor(isFirstResponder: self.$firstResponder, text: self.$text, height: self.$textViewHeight,autocapitalizationType: self.autocapitalizationType).frame(maxWidth: .infinity, maxHeight: .infinity).frame(height: textViewHeight)
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}
extension String {
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        if self.count < 1 {
            label.text = "   "
        } else {
            label.text = self
        }
        label.font = font
        label.sizeToFit()
        return label.frame.height
    }
}
struct LBTextViewEditor: UIViewRepresentable {
    enum State {
        case changed
        case done
        case cancel
        case next
        case prev
    }
    @Binding var isFirstResponder: Bool
    @Binding var text: String
    @Binding var height: CGFloat
    var autocapitalizationType:UITextAutocapitalizationType = .sentences
    let view = UITextView()
    func makeUIView(context: Context) -> UITextView {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.barTintColor = UIColor.clear
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolbar.tintColor = UIColor(named: "AccentColor")
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        let done = UIBarButtonItem(title: "Klar", style: .plain, target: context.coordinator, action: #selector(context.coordinator.done))
        //let cancel = UIBarButtonItem(title: "Avbryt", style: .plain, target: context.coordinator, action: #selector(context.coordinator.cancel))
        var items = [UIBarButtonItem]()
        
        //items.append(cancel)
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(done)
        toolbar.setItems(items, animated: false)
        
        let v = UIInputView(frame: toolbar.bounds)
        v.addSubview(toolbar)
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = true
        view.alwaysBounceHorizontal = false
        view.alwaysBounceVertical = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = UIColor.clear
        view.textColor = UIColor.label
        view.font = UIFont.systemFont(ofSize: 17)
        view.delegate = context.coordinator
        view.contentInset = .zero
        view.verticalScrollIndicatorInsets.bottom = -10
        view.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
        view.clipsToBounds = true
        view.inputAccessoryView = v
        view.textContainer.lineBreakMode = .byCharWrapping
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.text = self.text
        view.autocapitalizationType = autocapitalizationType
        view.sizeToFit()
        update(view: view)
        return view
    }
    func update(view:UITextView) {
        let font = view.font ?? UIFont.systemFont(ofSize: 17)
        height = text.height(constraintedWidth: view.contentSize.width, font: font)
    }
    func update(height:CGFloat) {
        if self.height != height {
            self.height = height
        }
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        if view.frame.size.width > 0 {
            DispatchQueue.main.async {
                context.coordinator.triggerUpdate(using: self.view)
            }
        }
        if text != uiView.text {
            uiView.text = text
            DispatchQueue.main.async {
                context.coordinator.triggerUpdate(using: self.view)
            }
        }
    }
    func makeCoordinator() -> LBTextViewEditor.Coordinator {
        return Coordinator(host: self)
    }
    class Coordinator: NSObject, UITextViewDelegate {
        var host:LBTextViewEditor
        init(host: LBTextViewEditor) {
            self.host = host
        }
        func textViewDidChange(_ textView: UITextView) {
            if host.text != textView.text {
                host.text = textView.text
            }
            triggerUpdate(using: textView)
        }
        func triggerUpdate(using view:UITextView) {
            let font = view.font ?? UIFont.systemFont(ofSize: 16)
            let height = view.text.height(constraintedWidth: view.contentSize.width, font: font)
            host.update(height: ceil(height))
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            self.resignFirstResponder()
        }
        func resignFirstResponder() {
            if self.host.isFirstResponder == true {
                self.host.isFirstResponder = false
            }
        }
        @objc func done() {
            self.host.view.resignFirstResponder()
            self.resignFirstResponder()
        }
        @objc func cancel() {
            self.host.view.text = self.host.text
            self.host.view.resignFirstResponder()
            self.resignFirstResponder()
        }
        @objc func next() {
            self.resignFirstResponder()
        }
        @objc func prev() {
            self.resignFirstResponder()
        }
    }
}

struct TextView_Previews: PreviewProvider {
    class Item: ObservableObject {
        @Published var text:String = "test"
    }
    @ObservedObject static var  item = Item()
    static var previews: some View {
        LBTextView("Test",text: $item.text)
    }
}
