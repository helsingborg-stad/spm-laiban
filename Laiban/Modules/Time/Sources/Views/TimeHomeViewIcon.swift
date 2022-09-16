
import SwiftUI

private let clockViewModel:ClockViewModel = {
    let m = ClockViewModel()
    m.showTimeSpan = false
    m.showItems = false
    m.showClockSeconds = false
    m.showShadow = false
    m.faceColor = Color.clear
    return m
}()

public struct TimeHomeViewIcon : View {
    public var body:some View {
        LBBadgeView(rimColor: Color("RimColorClock", bundle: .module)) { diameter in
            ClockView(clockViewModel)
        }
    }
    public init() {
        
    }
}
