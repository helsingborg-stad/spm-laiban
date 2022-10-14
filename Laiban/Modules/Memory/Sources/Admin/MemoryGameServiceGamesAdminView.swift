//
//  AdminDefaultMemoryGamesView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-14.
//

import SwiftUI
import Analytics

struct MemoryGameServiceGamesAdminView: View {
    @ObservedObject var service:MemoryGameService
    func toggle(_ game:DefaultMemoryGame) {
        if service.data.defaultMemoryGames.contains(game) == true {
            service.data.defaultMemoryGames.removeAll { l in l == game }
        } else {
            service.data.defaultMemoryGames.append(game)
        }
    }
    func contains(_ game:DefaultMemoryGame) -> Bool{
        return service.data.defaultMemoryGames.contains(game) == true
    }
    var body: some View {
        Form() {
            Section(header: Text("Välj spel")) {
                ForEach(DefaultMemoryGame.allCases) { game in
                    Button(action: {
                        self.toggle(game)
                    }) {
                        HStack() {
                            Image(systemName: self.contains(game) ? "checkmark.circle.fill" : "circle")
                                .imageScale(.large)
                                .foregroundColor(Color.accentColor)
                            Text(game.title).foregroundColor(Color.black)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
        .navigationBarTitle("Memoryspel")
    }
}

struct AdminDefaultMemoryGamesView_Previews: PreviewProvider {
    static var service = MemoryGameService()
    static var previews: some View {
        MemoryGameServiceGamesAdminView(service: service)
    }
}
