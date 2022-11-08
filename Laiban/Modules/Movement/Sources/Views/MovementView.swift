//
//  SwiftUIView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-25.
//

import SwiftUI
import Assistant
import Analytics

public struct MovementView: View {
    func columns(items: Int) -> Int {
        if properties.layout == .landscape {
            if verticalSizeClass == .compact {
                return 7
            }
            return 4
        }
        return 3
    }
    
    func padding(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width * 0.04
    }
    
    func itemSize(_ proxy: GeometryProxy, columns: Int) -> CGFloat {
        return (proxy.size.width - padding(proxy) * CGFloat(columns + 1)) / CGFloat(columns)
    }
    
    
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @ObservedObject var service:MovementService
    @StateObject var manager = MovementViewModel()
    
    public init(service:MovementService) {
        self.service = service
    }
    func cancelParentalGate() {
        manager.setCurrentView(.statistics)
    }
    var statistics: some View {
        GeometryReader { proxy in
            
            ZStack {
                VStack{
                    Spacer()
                    Image("MovementBackground", bundle: .module)
                        .resizable()
                        .padding(.top, 250)
                        .padding([.bottom, .leading, .trailing], 20)
                }
                VStack {
                    if manager.title != nil {
                        Text(manager.title!.display)
                            .font(properties.font, ofSize: .n)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                    MovementTableView(movementManager: service.movementManager, statistics: manager.weeklyStatistics) { scale, action in
                        if scale.date > Date() {
                            return
                        }
                        manager.selectedDate = scale.date
                        if action == .didPressIcon {
                            manager.setCurrentView(.activityChooser)
                        } else {
                            if service.movementManager.movement(for: scale.date) != nil {
                                manager.setCurrentView(.dailyMovemnent)
                            } else {
                                manager.setCurrentView(.enterNumMoving)
                            }
                        }
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color("TableBackgroundEnds",bundle:.module), Color("TableBackgroundMiddle",bundle:.module), Color("TableBackgroundEnds",bundle:.module)]), startPoint: .bottom, endPoint: .top)
                    )
                    .cornerRadius(20, corners: .allCorners)
                    .padding([.top, .bottom], 100)
                    //.frame(maxWidth:.infinity, maxHeight: .infinity)
                }
                .padding(.top, 10)
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .padding(proxy.size.width * 0.08)
                
            }
                .primaryContainerBackground()
                .transition(.opacity.combined(with: .scale))
                .onAppear {
                    AnalyticsService.shared.logPageView(self)
                }
        }
    }
    var dailyStatistics: some View {
        return MovementDailyStatisticsView(service: service, date: manager.selectedDate)
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .transition(.opacity.combined(with: .scale))
        .onAppear {
            AnalyticsService.shared.logPageView("MovementView/DailyMovementStatistics")
        }
    }
    var activityChooser: some View {
        GeometryReader { proxy in
            VStack {
                if manager.title != nil {
                    Text(manager.title!.display)
                        .font(properties.font, ofSize: .n)
                        .multilineTextAlignment(.center)
                }
                Spacer()

                let columns = columns(items: service.data.activities.count)
                ScrollView {
                    LBGridView(items: service.data.activities.count, columns: columns, horizontalSpacing: self.padding(proxy), verticalAlignment: .top) { index in
                        MovementActivitiyView(activity: service.data.activities[index]) { activity in
                            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"MovementActivity","Activity":activity.title])
                            if let toSpeak = activity.localizationKey {
                                assistant.speak([toSpeak])
                            }
                            manager.setCurrentView(.enterMovementTime)
                        }
                        .frame(width:itemSize(proxy, columns: columns),height:itemSize(proxy, columns: columns) * 1.1)
                        .animation(Animation.easeInOut(duration: 0.2))
                        
                    }
                    .padding(.top, 100)
                    .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top)
                    .font(.system(size: itemSize(proxy, columns: columns) * 0.10, weight: .semibold, design: .rounded))
                }
            }
            .padding(.top, 100)
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            .padding(0)
            .primaryContainerBackground()
            .parentalGate(properties: properties)
            .transition(.opacity.combined(with: .scale))
        }
    }
    
    var register: some View {
        RegisterMovementView(manager: manager, service:service)
            .transition(.opacity.combined(with: .scale))
    }
    @ViewBuilder var root: some View {
        if manager.currentView == .statistics {
            statistics
        } else if manager.currentView == .enterMovementTime || manager.currentView == .enterNumMoving  {
            register
        } else if manager.currentView == .activityChooser {
            activityChooser
        } else if manager.currentView == .dailyMovemnent {
            dailyStatistics
        }
    }
    public var body:some View {
        Group {
            root
        }
        .animation(.spring(),value:manager.currentView)
        .onAppear {
            manager.initiate(with: assistant,service:service, viewState: viewState)
        }
        .onReceive(properties.actionBarNotifier) { action in
            if action == .back {
                manager.setCurrentView(.statistics)
            }
        }
    }
}

struct MovementView_Previews: PreviewProvider {
    static var service = MovementService()

    static var previews: some View {
        LBFullscreenContainer { _ in
            MovementView(service: service)
        }
        .attachPreviewEnvironmentObjects()
    }
}
