//
//  Created by Tomas Green on 2021-08-03.
//

import SwiftUI

struct ClockAngle {
    var hour:Angle
    var minute:Angle
    var second:Angle
    static var now:ClockAngle {
        return angle(from: Date())
    }
    static func angle(from date:Date) -> ClockAngle {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)
        let h = Angle(degrees: Double(360/12 * hour) + Double(360/60 * minute) / 12)
        let m = Angle(degrees: Double(360/60 * minute) + Double(360/60 * second) / 60)
        let s = Angle(degrees: Double(360/60 * second))
        return ClockAngle(hour: h, minute: m, second: s)
    }
}

