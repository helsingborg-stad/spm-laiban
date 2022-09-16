//
//  ViewExtensions.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-19.
//

import SwiftUI

extension View {
   @ViewBuilder func modifyIf<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
    func invisible(_ bool:Bool = true) -> some View {
        self.disabled(bool).opacity(bool ? 0: 1)
    }
}
