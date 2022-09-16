//
//  SafariVIew.swift
//
//  Created by Tomas Green on 2020-11-03.
//

import SwiftUI
import SafariServices

public struct SafariView: UIViewControllerRepresentable {
    public let url: URL
    public init(url:URL) {
        self.url = url
    }
    public func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}
