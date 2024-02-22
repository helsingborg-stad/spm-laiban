import SwiftUI

public struct ImageGeneratorViewIcon: View {
    public var body: some View {
        LBBadgeView(rimColor: .black) { _ in
            Image("icon", bundle: .module)
                .centerCropped()
                .scaleEffect(CGSize(width: 1.01, height: 1.01))
        }
    }

    public init() {}
}

struct ImageGeneratorViewIcon_Previews: PreviewProvider {
    static var previews: some View {
        ImageGeneratorViewIcon()
    }
}
