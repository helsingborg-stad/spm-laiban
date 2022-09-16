import SwiftUI

public struct ActivitiesHomeViewIcon : View {
    public var body:some View {
        LBEmojisBadgeView(centerEmoji: "🎨", surroundingEmojis: ["🎒", "🤸‍♂️", "👩‍💻", "🎸", "⚽️","🧩","🌳","✏️"], rimColor: Color("RimColorActivities", bundle: .module))
    }
    public init() {
        
    }
}
