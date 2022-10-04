//
//  SwiftUIView.swift
//  
//
//  Created by Ehsan Zilaei on 2022-09-22.
//

import SwiftUI

struct ParticipantsAdminView: View {
    private var viewModel: ParticipantsAdminViewModel
    @State var sortedParticipants = [String]()
    
    init(service: ParticipantService) {
        viewModel = ParticipantsAdminViewModel(service: service)
    }
    
    var body: some View {
        NavigationLink(destination: LBParticipantsView(allParticipants: $sortedParticipants,
                                                       updateParticipant: viewModel.updateParticipants))
        {
            HStack {
                Text("Deltagare")
            }
        }
        .onReceive(viewModel.participantPublisher) {
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
