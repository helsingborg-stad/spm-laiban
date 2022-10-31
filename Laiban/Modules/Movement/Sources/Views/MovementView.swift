//
//  SwiftUIView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-25.
//

import SwiftUI
import Assistant

public struct MovementView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
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
                    if action == .didPressIcon && service.movementManager.movement(for: scale.date) != nil {
                        manager.setCurrentView(.balanceScale)
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
                .padding([.top, .bottom], 100)
            }
            .padding(.top, 10)
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .padding(proxy.size.width * 0.1)
            .primaryContainerBackground()
            .transition(.opacity.combined(with: .scale))
            .onAppear {
                print("Data array: \(service.data)")
                print("Data count: \(service.data.count)")
                LBAnalyticsProxy.shared.logPageView(self)
        }
        }
    }
    var balanceScaleView: some View {
        Text("Hello there")
    }
    var dailyStatistics: some View {
        Text("Hello there")
    }
    var register: some View {
        Text("Hello there")
    }
    @ViewBuilder var root: some View {
        if manager.currentView == .statistics {
            statistics
        } else if manager.currentView == .enterMovementTime || manager.currentView == .enterNumMoving  {
            register
        } else if manager.currentView == .balanceScale {
            balanceScaleView
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
            viewState.characterImage(Monster(name:"Kompostina").image, for: .movement)
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
