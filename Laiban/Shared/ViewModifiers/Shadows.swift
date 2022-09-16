//
//  Created by Tomas Green on 2020-03-18.
//

import SwiftUI

struct LBShadow: ViewModifier {
    var isEnabled:Bool = true
    func body(content: Content) -> some View {
        content.shadow(color: Color.black.opacity(isEnabled ? 0.3 : 0), radius: 4, x: 0, y: 0)
    }
}

public extension View {
    func shadow(enabled:Bool = true, forSize size:CGFloat = 100) -> some View {
        self.shadow(color: Color.black.opacity(enabled ? 0.3 : 0), radius: size * 0.04, x: 0, y: 0)
    }
}
