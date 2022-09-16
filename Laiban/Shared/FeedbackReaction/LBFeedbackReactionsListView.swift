import SwiftUI
import Combine
import Assistant

public struct LBFeedbackReactionsListView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @EnvironmentObject var assistant:Assistant
    public var onRate: (LBFeedbackReaction) -> Void
    public init(_ onRate: @escaping (LBFeedbackReaction) -> Void) {
        self.onRate = onRate
    }
    public var body: some View {
        HStack(spacing: properties.spacing[.s]) {
            ForEach(LBFeedbackReaction.allCases, id:\.rawValue) { reaction in
                Button(action: {
                    onRate(reaction)
                }) {
                    LBEmojiBadgeView(emoji: reaction.emoji, rimColor: reaction.color)
                        .aspectRatio(1,contentMode: .fit)
                        .frame(width: properties.contentSize.height * 0.055, height: properties.contentSize.height * 0.055)
                }
            }
        }
    }
}

