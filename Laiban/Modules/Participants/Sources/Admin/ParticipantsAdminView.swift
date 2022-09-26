//
//  SwiftUIView.swift
//  
//
//  Created by Ehsan Zilaei on 2022-09-22.
//

import SwiftUI

struct ParticipantsAdminView: View {
    private var vm: ParticipantsAdminViewModel
    @State var sortedParticipants = [String]()
    
    init(service: ParticipantService) {
        vm = ParticipantsAdminViewModel(service: service)
    }
    
    var body: some View {
        NavigationLink(destination: LBParticipantsView(allParticipants: $sortedParticipants,
                                                       updateParticipant: vm.updateParticipants))
        {
            HStack {
                Text("Deltagare")
            }
        }
        .onReceive(vm.participantPublisher) {
            sortedParticipants = $0.sorted()
        }
    }
}

struct ParticipantsAdminView_Previews: PreviewProvider {
    static var service = ParticipantService()
    
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    ParticipantsAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
