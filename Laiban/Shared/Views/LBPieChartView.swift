//
//  PieChartView.swift
//
//  Created by Tomas Green on 2020-06-08.
//

import SwiftUI

public struct LBPieChartSlice: View {
    struct Slice: Identifiable {
        let id: UUID = UUID()
        var color:Color
        var startAngle: Angle! = .degrees(0)
        var endAngle: Angle! = .degrees(0)
    }
    var geometry: GeometryProxy
    var slideData: Slice
    var lineWidth:CGFloat = 5
    var path: Path {
        
        let chartSize = geometry.size.width + lineWidth * 2
        let radius = chartSize / 2
        let centerX = radius - lineWidth
        let centerY = radius - lineWidth
        
        var path = Path()
        path.move(to: CGPoint(x: centerX, y: centerY))
        path.addArc(center: CGPoint(x: centerX, y: centerY),
                    radius: radius,
                    startAngle: slideData.startAngle,
                    endAngle: slideData.endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
    
    public var body: some View {
        path.fill(slideData.color).overlay(path.stroke(Color.white, style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .round)))
    }
}
public struct LBPieChart: View {
    func convert(items:[LBGraphItem]) -> [LBPieChartSlice.Slice]{
        var slizes = [LBPieChartSlice.Slice]()
        var prev:Double = -90
        for a in items {
            let start = Angle(degrees: prev)
            let end = Angle(degrees: prev + 360 * Double(a.percentage))
            slizes.append(LBPieChartSlice.Slice(color: a.color, startAngle: start, endAngle: end))
            prev = end.degrees
        }
        return slizes
    }
	var lineWidth:CGFloat = 5
    var items:[LBGraphItem]
    public init(lineWidth:CGFloat = 5, items:[LBGraphItem]) {
        self.lineWidth = lineWidth
        self.items = items
    }
    public var body: some View {
        Circle().overlay(
            GeometryReader { geometry in
                ForEach(self.convert(items: self.items)) { item in
                    LBPieChartSlice(geometry: geometry, slideData: item, lineWidth:self.lineWidth).frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.aspectRatio(1, contentMode: .fit).clipShape(Circle())
        )
    }
}
struct PieChartSlide_Previews: PreviewProvider {
    static var items:[LBGraphItem] {
        var arr = [LBGraphItem]()
        arr.append(LBGraphItem(color: Color("FeedbackColor\(LBFeedbackReaction.veryHappy.rawValue)"), emoji: LBFeedbackReaction.veryHappy.emoji, percentage: 0.25))
        arr.append(LBGraphItem(color: Color("FeedbackColor\(LBFeedbackReaction.happy.rawValue)"), emoji: LBFeedbackReaction.happy.emoji, percentage: 0.5))
        arr.append(LBGraphItem(color: Color("FeedbackColor\(LBFeedbackReaction.neutral.rawValue)"), emoji: LBFeedbackReaction.neutral.emoji, percentage: 0.2))
        arr.append(LBGraphItem(color: Color("FeedbackColor\(LBFeedbackReaction.sad.rawValue)"), emoji: LBFeedbackReaction.sad.emoji, percentage: 0.05))
        return arr
    }
    static var previews: some View {
        LBPieChart(items: items)
    }
}
