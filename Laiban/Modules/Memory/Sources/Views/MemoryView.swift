//
//  MemoryView.swift
//
//  Created by Tomas Green on 2021-02-23.
//

import SwiftUI
import Combine
import Assistant

public struct MemoryView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @ObservedObject var service:MemoryGameService
    @State var selectedDeck:DefaultMemoryGame? = nil
    
    public init(service:MemoryGameService) {
        self.service = service
        let games = service.data.defaultMemoryGames
        if games.count > 1 {
            if service.data.memoryGamesAtRandomEnabled == true {
                self._selectedDeck = .init(initialValue: games.randomElement()!)
            } else {
                self._selectedDeck = .init(initialValue:nil)
            }
        } else if games.count == 1 {
            self._selectedDeck = .init(initialValue: games.first!)
        }
    }
    func selectDeck(_ deck: DefaultMemoryGame) {
        self.selectedDeck = deck
    }
    fileprivate func createChooseUndpButton() -> some View {
        let imageSize = properties.contentSize.width * (horizontalSizeClass == .regular ? 0.25 : 0.3)
        return Button(action: {
            selectDeck(.undp)
            LBAnalyticsProxy.shared.log("Memory-UNDPSelected", category: "Memory", action: "Button")
        }, label: {
            VStack {
                LBImageBadgeView(image: UNDPGoal.logotype, rimColor: Color("RimColorGames", bundle: LBBundle))
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                Text(LocalizedStringKey("memory_game_default_undp"), bundle: LBBundle)
                    .font(properties.font, ofSize: .n)
                    .lineLimit(2)
            }
        })
    }
    fileprivate func createChooseTrashmonsterButton() -> some View {
        let imageSize = properties.contentSize.width * (horizontalSizeClass == .regular ? 0.25 : 0.3)
        return Button(action: {
            selectDeck(.trashmonsters)
            LBAnalyticsProxy.shared.log("Memory-TrashMonstersSelected", category: "Memory", action: "Button")
        }, label: {
            VStack {
                LBEmojiBadgeView(emoji: "♻️", rimColor: Color("RimColorGames", bundle: LBBundle))
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                Text(LocalizedStringKey("memory_game_default_trashmonsters"), bundle: LBBundle)
                    .font(properties.font, ofSize: .n)
                    .lineLimit(2)
            }
        })
    }
    var chooseBody: some View {
        VStack {
            Text(LocalizedStringKey("memory_game_choose"), bundle: LBBundle)
                .font(properties.font, ofSize: .xl)
                .padding(.bottom, 40)
            
            if horizontalSizeClass == .regular {
                HStack(spacing: 60) {
                    createChooseUndpButton()
                    createChooseTrashmonsterButton()
                }
            } else {
                VStack(spacing: 20) {
                    createChooseUndpButton()
                    createChooseTrashmonsterButton()
                }
            }
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .multilineTextAlignment(.center)
        .onAppear {
            assistant.speak([
                ("memory_game_choose","memory_game_choose"),
                ("memory_game_default_undp","memory_game_default_undp"),
                ("word_or","word_or"),
                ("memory_game_default_trashmonsters","memory_game_default_trashmonsters"),
            ])
            LBAnalyticsProxy.shared.logPageView("MemoryView/Choose")
        }
        .animation(.spring(), value: selectedDeck)
        .transition(.opacity.combined(with: .scale))
    }
    public var body: some View {
        if selectedDeck == .trashmonsters {
            TrashMontersMemoryGameView(service: service)
        } else if selectedDeck == .undp {
            UNDPMemoryGameView(service: service)
        } else {
            chooseBody
        }
    }
}
struct MemoryView_Previews: PreviewProvider {
    static var service = MemoryGameService()
    static var previews: some View {
        LBFullscreenContainer { _ in
            MemoryView(service:service)
        }.attachPreviewEnvironmentObjects()
    }
}
