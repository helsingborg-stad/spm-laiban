//
//  TrashMontersView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-01.
//

import SwiftUI
import Combine
import Assistant

struct TrashMontersMemoryGameView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @ObservedObject var service:MemoryGameService
    
    @StateObject private var memoryViewModel = MemoryGameViewModel(layout: .medium)
    @State private var title:[String] = ["memory_game_start"]
    @State private var cancellables = Set<AnyCancellable>()
    @State private var currentMonster:MonsterMemory? = nil
    var body: some View {
        VStack {
            if currentMonster != nil {
                if horizontalSizeClass == .regular {
                    MonsterInfoRegularView(monster: currentMonster!.monster)
                        .frame(height: properties.contentSize.height * 0.2)
                } else {
                    MonsterInfoCompactView(monster: currentMonster!.monster)
                }
            } else {
                ForEach(title, id:\.self) { s in
                    Text(LocalizedStringKey(s), bundle: LBBundle)
                        .font(properties.font, ofSize: .l,weight: .bold)
                }
            }
            Spacer()
            MemoryGameView<MonsterMemory>(model: memoryViewModel)
        }
        .onReceive(memoryViewModel.$lastFound) { object in
            guard let obj = memoryViewModel.lastFound as? MonsterMemory else {
                return
            }
            currentMonster = obj
            assistant.speak(obj.decription).last?.statusPublisher.sink(receiveValue: { s in
                if s != .finished {
                    return
                }
                currentMonster = nil
                if memoryViewModel.status == .done {
                    title = [
                        "memory_game_finished",
                        "memory_game_play_again"
                    ]
                    assistant.speak(title)
                }
            }).store(in: &cancellables)
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            assistant.speak("memory_game_start")
            LBAnalyticsProxy.shared.logPageView("MemoryView/TrashMonsters")
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
