//
//  participantsListView.swift
//
//  Created by Tomas Green on 2020-05-04.
//

import SwiftUI
import Combine

struct AdminParticipantsView: View {
    @State var activityParticipants: [String]
    var service: ActivityService
    var completionHandler: (([String]) -> Void)? = nil
    
    @State private var newParticipant: String = ""
    @State private var showAlertParticipantExist = false
    @State private var allParticipants = [String]()
    
    var body: some View {
        Form {
            Section() {
                createNewParticipant
            }
            Section(footer:Text("Observera att radering av deltagare påverkar alla aktivieter.").foregroundColor(.red).font(.system(size: 16))) {
                listParticipants
            }
        }
        .navigationBarTitle(Text("Deltagare"))
        .onDisappear {
            self.completionHandler?(activityParticipants)
        }
        .onReceive(service.$participantsPublisher) {
            allParticipants = $0.sorted()
        }
    }
}

extension AdminParticipantsView {
    private var createNewParticipant: some View {
        HStack {
            TextField("Skapa ny deltagare", text: $newParticipant)
                .disableAutocorrection(true)
            Button(action: {
                if allParticipants.contains(newParticipant) {
                    showAlertParticipantExist = true
                    
                    return
                }
                
                withAnimation {
                    service.updateParticipant(participant: newParticipant, action: .add)
                    newParticipant = ""
                }
                                
            }) {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(newParticipant.isEmpty)
            .alert(isPresented: $showAlertParticipantExist) {
                Alert(title: Text("Deltagare finns redan"))
            }
        }
    }
    
    private var listParticipants: some View {
        ForEach($allParticipants, id:\.self) { $participant in
            HStack {
                Button(action: {
                    if let i = activityParticipants.firstIndex(of: participant) {
                        activityParticipants.remove(at: i)
                    } else {
                        activityParticipants.append(participant)
                    }
                    
                }) {
                    Image(systemName: activityParticipants.contains(participant) ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                }
                Text(participant)
            }
        }
        .onDelete { indices in
            for i in indices {
                withAnimation {
                    activityParticipants.removeAll { $0 == allParticipants[i] }
                }
                service.updateParticipant(participant: allParticipants[i], action: .remove)
            }
        }
    }
}
