//
//  Created by Tomas Green on 2021-05-11.
//

import SwiftUI

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}
extension Int {
    func ranges(seperatedInto columns:Int) -> [ClosedRange<Int>] {
        var arr = [ClosedRange<Int>]()
        guard self > 0 else {
            return []
        }
        if self <= columns {
            return [ClosedRange(0..<self)]
        }
        for index in 0...self {
            if index % columns == 0 {
                let lower = index
                let upper = lower + columns
                if upper > self - 1 {
                    arr.append(ClosedRange(lower..<self))
                    break
                } else {
                    arr.append(ClosedRange(lower..<upper))
                }
            }
        }
        return arr
    }
}
