//
//  BarGraphView.swift
//
//  Created by Tomas Green on 2020-06-08.
//

import SwiftUI

public struct LBGraphItem : Identifiable {
    public let id:String
    public let color:Color
    public let emoji:String
    public let percentage:CGFloat
    public var text:String {
        return "\(Int(percentage * 100))%"
    }
    public init(id:String = UUID().uuidString, color:Color, emoji:String, percentage:CGFloat) {
        self.id = id
        self.color = color
        self.emoji = emoji
        self.percentage = percentage
    }
}
public struct LBBarGraphView: View {
    public enum Size {
        case normal
        case large
        var emojiFontSize:CGFloat {
            switch self {
            case .normal: return 25
            case .large: return 28
            }
        }
        var percentageFontSize:CGFloat {
            switch self {
            case .normal: return 15
            case .large: return 17
            }
        }
        var percentageWidth:CGFloat {
            switch self {
            case .normal: return 50
            case .large: return 55
            }
        }
        var height:CGFloat {
            switch self {
            case .normal: return 20
            case .large: return 21
            }
        }
        var verticalSpacing:CGFloat {
            switch self {
            case .normal: return 4
            case .large: return 5
            }
        }
        var horizontalSpacing:CGFloat {
            switch self {
            case .normal: return 5
            case .large: return 5
            }
        }
    }
    var data:[LBGraphItem]
    var size:Size = .normal
    public init(data:[LBGraphItem] , size:Size = .normal) {
        self.data = data
        self.size = size
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: self.size.verticalSpacing) {
            ForEach(data,id:\.emoji) { row in
                HStack(spacing: self.size.horizontalSpacing) {
                    Text(row.emoji)
                        .font(.system(size: self.size.emojiFontSize))
                    GeometryReader() { proxy in
                        HStack(spacing: 0) {
                            Rectangle().foregroundColor(row.color).frame(width: proxy.size.width * row.percentage, height: self.size.height)
                            Rectangle().foregroundColor(.gray).opacity(0.2).frame(height: self.size.height)
                        }
                    }.frame(height: self.size.height)
                    Text(row.text)
                        .font(.system(size: self.size.percentageFontSize,weight: .semibold,design: .rounded))
                        .frame(width: self.size.percentageWidth, alignment: .trailing)
                }
            }
        }
    }
}

//struct BarGraphView_Previews: PreviewProvider {
//    static var data:[GraphItem] {
//        var arr = [GraphItem]()
//        arr.append(GraphItem(color: Color("FeedbackColor\(FeedbackReaction.veryHappy.rawValue)"), emoji: FeedbackReaction.veryHappy.emoji, percentage: 0.25))
//        arr.append(GraphItem(color: Color("FeedbackColor\(FeedbackReaction.happy.rawValue)"), emoji: FeedbackReaction.happy.emoji, percentage: 0.5))
//        arr.append(GraphItem(color: Color("FeedbackColor\(FeedbackReaction.neutral.rawValue)"), emoji: FeedbackReaction.neutral.emoji, percentage: 0.2))
//        arr.append(GraphItem(color: Color("FeedbackColor\(FeedbackReaction.sad.rawValue)"), emoji: FeedbackReaction.sad.emoji, percentage: 0.05))
//        return arr
//    }
//    static var previews: some View {
//        BarGraphView(data: data)
//    }
//}
