//
//  RegisterMovementView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-02.
//

import SwiftUI
import Assistant
import Analytics

struct RegisterMovementView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @ObservedObject var manager:MovementViewModel
    @ObservedObject var service:MovementService
    @State var numMoving:Int = 0
    @State var movementTime:Int = 0
    @State var numpadString:String = ""

    func evalNumMoving() {
        if numpadString.count > 0, let moving = Int(numpadString) {
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"NumberOfPeopleMoving"])
            numMoving = moving
            numpadString = ""
            service.movementManager.add(value: movementTime, numMoving: numMoving, for: manager.selectedDate)
            manager.setCurrentView(.dailyMovemnent)
        }
    }
    
    func evalNumTime() {
        if numpadString.count > 0, let time = Int(numpadString) {
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"MovementTime"])
            movementTime = time
            numpadString = ""
            manager.setCurrentView(.enterNumMoving)
        }
    }

    var enterMovementTime: some View {
        VStack() {
            Text("⏱").padding(.bottom, 10)
                .font(properties.font, ofSize: .xxl)
            Text(assistant.string(forKey: "movement_register_how_long"))
                .font(properties.font, ofSize: .l)
            Spacer()
            HStack(alignment:.bottom) {
                Text(numpadString.count > 0 ? numpadString : "0")
                Text("min").foregroundColor(.gray)
            }
            .font(properties.font, ofSize: .n)
            Rectangle()
                .frame(width: properties.windowRatio * 100 * 4 + properties.windowRatio * 20 * 2, height:1)
                .padding(.bottom, properties.windowRatio * 20)
            LBNumpadView(maxNum: manager.maxMinutesOfActivity, string: $numpadString).padding(30)
            Spacer()
            Button(action: evalNumTime, label: {
                Text(assistant.string(forKey: "movement_next"))
                    .padding()
                    .frame(width: properties.windowRatio * 100 * 5)
                    .font(properties.font, ofSize: .l,color:.white)
                    .background(Color("DefaultTextColor", bundle:.module))
                    .cornerRadius(properties.windowRatio * 100/2)
                    .shadow(enabled: true)
            }).foregroundColor(Color.white).disabled(numpadString.count < 1).opacity(numpadString.count < 1 ? 0.5 : 1)
            Spacer()
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            AnalyticsService.shared.logPageView("Movement/EnterMovementTime")
            numpadString = ""
        }
    }
    var enterNumberOfPeople: some View {
        VStack() {
            Text("👩‍👧‍👦👨‍👧‍👦").padding(.bottom, 10)
                .font(properties.font, ofSize: .xxl)
            Text(assistant.string(forKey: "movement_register_how_many"))
                .font(properties.font, ofSize: .l)
            Spacer()
            HStack(alignment:.bottom) {
                Text(numpadString.count > 0 ? numpadString : "0")
                Text("st").foregroundColor(.gray)
            }
            .font(properties.font, ofSize: .n)
            Rectangle()
                .frame(width: properties.windowRatio * 100 * 4 + properties.windowRatio * 20 * 2, height:1)
                .padding(.bottom, properties.windowRatio * 20)
            LBNumpadView(maxNum: manager.maxNumberOfPeople, string: $numpadString).padding(30)
            Spacer()
            Button(action: evalNumMoving, label: {
                Text(assistant.string(forKey: "movement_register"))
                    .padding()
                    .frame(width: properties.windowRatio * 100 * 5)
                    .font(properties.font, ofSize: .l,color:.white)
                    .background(Color("DefaultTextColor", bundle:.module))
                    .cornerRadius(properties.windowRatio * 100/2)
                    .shadow(enabled: true)
            }).foregroundColor(Color.white).disabled(numpadString.count < 1).opacity(numpadString.count < 1 ? 0.5 : 1)
            Spacer()
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            AnalyticsService.shared.logPageView("Movement/EnterNumberOfPeopleMoving")
            numpadString = ""
        }
    }
    var body: some View {
        if manager.currentView == .enterMovementTime {
            enterMovementTime
        } else if manager.currentView == .enterNumMoving {
            enterNumberOfPeople
        } else {
            EmptyView()
        }
    }
}
