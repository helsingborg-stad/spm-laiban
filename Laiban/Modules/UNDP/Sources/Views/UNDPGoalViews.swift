//
//  UNDPGoalViews.swift
//  Laiban
//
//  Created by Tomas Green on 2021-09-02.
//

import SwiftUI

public struct UNDPCircleView: View {
    public var goal: UNDPGoal
    public var size: CGFloat
    public init(goal: UNDPGoal,size: CGFloat) {
        self.goal = goal
        self.size = size
    }
    public var body: some View {
        goal.icon
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .padding(size * 0.2)
            .background(goal.backgroundColor)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: size * 0.05))
    }
}

//struct UNDPGoalViews_Previews: PreviewProvider {
//    static var previews: some View {
//        LBFullscreenContainer { _ in
//            UNDPCircleView(goal: .goal12, size: 100)
//        }.addPreviewAssistant()
//    }
//}
