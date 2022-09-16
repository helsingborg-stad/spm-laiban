//
//  ActivityIndicator.swift
//
//  Created by Tomas Green on 2020-06-08.
//

import SwiftUI

public struct LBActivityIndicator: UIViewRepresentable {
    @Binding public var isAnimating: Bool
    public let style: UIActivityIndicatorView.Style
    public init(isAnimating:Binding<Bool>,style:UIActivityIndicatorView.Style) {
        self._isAnimating = isAnimating
        self.style = style
    }
    public func makeUIView(context: UIViewRepresentableContext<LBActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<LBActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
