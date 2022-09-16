
import SwiftUI

public struct OutdoorsHomeViewIcon : View {
    @ObservedObject var service:OutdoorsService
    public init(service:OutdoorsService) {
        self.service = service
    }
    public var body:some View {
        LBEmojisBadgeView(centerEmoji: service.weather?.symbol.emoji ?? "🌥", surroundingEmojis:  ["☔️","👕","🥾","🧣","🧤","🧢","👖"], rimColor: Color("RimColorWeather", bundle: .module))
    }
}
