//
//  MovementActivitiesView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-01.
//

import SwiftUI
import Combine

import Assistant
struct MovementActivitiyView: View {
    @EnvironmentObject var assistant:Assistant
    var activity:MovementActivity
    var action:((MovementActivity) -> Void)
    var body: some View {
        GeometryReader { proxy in
            Button(action: {
                self.action(self.activity)
            }) {
                VStack(alignment: .center,spacing: 10) {
                    LBEmojiBadgeView(emoji: activity.emoji, rimColor: activity.color)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height:proxy.size.width * 0.6)
                    Text(assistant.string(forKey: activity.title).uppercased())
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("DefaultTextColor", bundle:.module))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct MovementActivitiesView_Previews: PreviewProvider {
    static let activity = MovementActivity(id: "1", colorString: MovementActivity.colorStrings.randomElement()!, title: "Springa", emoji: "🏃‍♀️", localizationKey: nil)
    
    static var previews: some View {
        MovementActivitiyView(activity: activity, action: {action in
        }).attachPreviewEnvironmentObjects()
    }
}
