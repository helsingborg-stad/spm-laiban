//
//  UNDPMemoryGameViews.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-29.
//

import SwiftUI
import Combine
import Assistant

struct UNDPGoalInfoCompactView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    var goal:MemoryUNDPGoal
    var imageSize:CGFloat {
        120
    }
    var body: some View {
        VStack(alignment:.center) {
            GeometryReader { geo in
                goal.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .foregroundColor(.white)
            .padding()
            .frame(width: imageSize, height: imageSize)
            .frame(maxWidth: .infinity)
            .background(goal.color)
            VStack(alignment:.leading,spacing:10) {
                Text(LocalizedStringKey(goal.title), bundle: LBBundle).fontWeight(.bold)
                Text(LocalizedStringKey(goal.decription), bundle: LBBundle)
            }
            .font(properties.font, ofSize: .n)
            .padding()
        }
        .lineLimit(nil).multilineTextAlignment(.leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(enabled: true)
    }
}
struct UNDPGoalInfoRegularView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    var goal:MemoryUNDPGoal
    var imageSize:CGFloat = 120
    var body: some View {
        HStack(alignment:.center) {
            VStack(alignment:.leading,spacing:10) {
                Text(LocalizedStringKey(goal.title), bundle: LBBundle).fontWeight(.bold)
                Text(LocalizedStringKey(goal.decription), bundle: LBBundle)
            }
            .frame(maxWidth:.infinity)
            .font(properties.font, ofSize: .n)
            .padding()
            .padding(.leading, imageSize + 10)
        }
        .overlay(
            HStack(spacing:0) {
                GeometryReader { geo in
                    goal.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: imageSize, height: imageSize)
                .frame(maxHeight: .infinity)
                .background(goal.color)
                Spacer()
            }
        )
        .lineLimit(nil).multilineTextAlignment(.leading)
        .frame(maxWidth:.infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(enabled: true)
    }
}

struct UNDPMemoryGameView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @ObservedObject var service:MemoryGameService
    
    @State private var title:[String] = ["memory_game_start"]
    @State private var cancellables = Set<AnyCancellable>()
    @State private var currentGoal:MemoryUNDPGoal? = nil
    @StateObject private var memoryViewModel = MemoryGameViewModel(layout: .medium)
    
    var body: some View {
        VStack {
            if currentGoal != nil {
                if horizontalSizeClass == .regular {
                    UNDPGoalInfoRegularView(goal: currentGoal!).id(currentGoal!.id)
                } else {
                    UNDPGoalInfoCompactView(goal: currentGoal!).id(currentGoal!.id)
                }
            } else {
                ForEach(title, id:\.self) { s in
                    Text(LocalizedStringKey(s), bundle: LBBundle)
                        .font(properties.font, ofSize: .l,weight: .bold)
                }
            }
            Spacer()
            MemoryGameView<MemoryUNDPGoal>(model: memoryViewModel)
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        
        .onReceive(memoryViewModel.$lastFound) { object in
            guard let obj = memoryViewModel.lastFound as? MemoryUNDPGoal else {
                return
            }
            currentGoal = obj
            assistant.speak([
                (obj.title,obj.title),
                (obj.decription,obj.decription)
            ]).last?.statusPublisher.sink(receiveValue: { s in
                if s != .finished {
                    return
                }
                currentGoal = nil
                if memoryViewModel.status == .done {
                    title = [
                        "memory_game_finished",
                        "memory_game_play_again"
                    ]
                    assistant.speak(title)
                }
            }).store(in: &cancellables)
        }
        .onAppear {
            assistant.speak("memory_game_start")
            LBAnalyticsProxy.shared.logPageView("MemoryView/UNDP")
        }
        .transition(.opacity.combined(with: .scale))
        .onRotate { o in
            if properties.layout == .portrait {
                memoryViewModel.cardLayout = .medium
            } else {
                memoryViewModel.cardLayout = .mediumWide
            }
        }
    }
}
