//
//  MovementDailyStatisticsView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-02.
//

import SwiftUI
import Assistant

struct MovementDailyStatisticsView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    
    @ObservedObject var service:MovementService
    
    var title:String {
        let str:String
        let a = Int(Date().timeIntervalSince(date) / 60 / 60 / 24)
        if a == 0 {
            str = "movement_statistics_title_today"
        } else if a == 1 {
            str = "movement_statistics_title_yesterday"
        } else {
            str = "movement_statistics_title_weekday_\(date.actualWeekDay)"
        }
        return assistant.formattedString(forKey: str, String(Int(service.movementManager.movementSteps(for: date))), String(service.movementManager.movementMeters(for: date)))
    }

    var date:Date
    var infoTitle:String? = nil
    var infoDescription:String? = nil
    var infoEmoji:String? = nil
    var body: some View {
        contentView
    }
    var contentView: some View {
        return GeometryReader { proxy in

            let model = MovementBarView.ViewModel(movementMeters: service.movementManager.movementMeters(for: date), settings: service.data.settings)
             VStack(spacing: 20) {
                Text(title)
                    .font(properties.font, ofSize: .n)
                    .multilineTextAlignment(.center)
                    .padding(.top,10)
                HStack(spacing: 50) {
                    MovementBarView(model: model).frame(maxWidth:.infinity).onTapGesture {
                    }
                    .animation(.ripple(index: 1))
                    .frame(maxWidth: proxy.size.width * 0.25, maxHeight:.infinity,alignment: .bottom)
                    .padding([.trailing],0)
                    .padding([.top, .bottom], 50)
                    .padding(.leading, 50)
                    
                    MovementFootsteps()
                        .padding([.trailing],50)
                        .padding([.top, .bottom], 50)
                        .padding(.leading, 0)
                }
                .frame(maxWidth: .infinity, maxHeight:.infinity,alignment: .bottom)

            }.frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)
                .padding(.top, 80)
        }
    }
    
}
