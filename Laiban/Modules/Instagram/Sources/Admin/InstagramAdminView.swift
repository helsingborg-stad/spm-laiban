//
//  InstagramAdminView.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-04.
//

import SwiftUI
import Combine
import Analytics

struct InstagramAdminView: View {
    @ObservedObject var service: InstagramService
    @State var showInstagramErrorAlert: Bool = false
    @State var instagramError: Error?
    @State var isAuthenticated: Bool = false
    @State var cancellables = Set<AnyCancellable>()
    var availableBody: some View {
        Button(action: {
            if service.instagram.isAuthenticated {
                service.instagram.logout()
                AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button": "UnLinkInstagramAccount"])
            } else {
                service.instagram.authorize().receive(on: DispatchQueue.main).sink { completion in
                    switch completion {
                    case .failure(let error):
                        instagramError = error
                        showInstagramErrorAlert = true
                    case .finished: break
                    }
                } receiveValue: {
                    instagramError = nil
                    showInstagramErrorAlert = false
                }
                .store(in: &cancellables)
            }
        }) {
            if isAuthenticated {
                Text("Koppla bort Instagram-konto").foregroundColor(.red)
            } else {
                Text("Länka Instagram-konto")
            }
        }
        .onReceive(service.instagram.$isAuthenticated, perform: { isUserAuthenticated in
            isAuthenticated = isUserAuthenticated
        })
        .alert(isPresented: $showInstagramErrorAlert) {
            Alert(title: Text(instagramError?.localizedDescription ?? "Kunde inte koppla användaren"))
        }
    }
    var notAvailableBody: some View {
        Text("Saknar konfiguration för Instagram").foregroundColor(Color(.secondaryLabel))
    }
    var body: some View {
        if service.instagram.config != nil {
            availableBody
        } else {
            notAvailableBody
        }
    }
}

struct InstagramAdminView_Previews: PreviewProvider {
    static var service = InstagramService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    InstagramAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
