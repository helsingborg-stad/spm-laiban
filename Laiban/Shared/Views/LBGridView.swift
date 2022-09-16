//
//  SwiftUIView.swift
//  
//
//  Created by Tomas Green on 2022-04-26.
//

import SwiftUI

public struct LBGridView<Content: View>: View {
    let grid: [ClosedRange<Int>]
    let content: (Int) -> Content
    let verticalSpacing:CGFloat
    let horizontalSpacing:CGFloat
    let horizontalAlignment :HorizontalAlignment
    let verticalAlignment :VerticalAlignment
    
    public var body: some View {
        VStack(alignment: horizontalAlignment, spacing: verticalSpacing) {
            ForEach(grid, id: \.self) { range in
                HStack(alignment: self.verticalAlignment, spacing: self.horizontalSpacing) {
                    ForEach(range, id: \.self) { index in
                        self.content(index)
                    }
                }
            }
        }
    }
    public static func value(_ value:Int, seperatedInto columns:Int) -> [ClosedRange<Int>] {
        var arr = [ClosedRange<Int>]()
        guard value > 0 else {
            return []
        }
        if value <= columns {
            return [ClosedRange(0..<value)]
        }
        for index in 0...value {
            if index % columns == 0 {
                let lower = index
                let upper = lower + columns
                if upper > value - 1 {
                    arr.append(ClosedRange(lower..<value))
                    break
                } else {
                    arr.append(ClosedRange(lower..<upper))
                }
            }
        }
        return arr
    }
    public init(items: Int, columns: Int, verticalSpacing:CGFloat = 0, horizontalSpacing:CGFloat = 0, verticalAlignment:VerticalAlignment = .center, horizontalAlignment:HorizontalAlignment = .center, @ViewBuilder content: @escaping (Int) -> Content) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.grid = Self.value(items, seperatedInto: columns)
        self.content = content
    }
}

struct LBGridView_Previews: PreviewProvider {
    static var previews: some View {
        LBGridView(items: 5, columns: 3, verticalSpacing: 10, horizontalSpacing: 10, verticalAlignment: .center, horizontalAlignment: .center) { index in
            Rectangle()
        }
    }
}
