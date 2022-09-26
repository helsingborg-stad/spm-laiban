//
//  ParticipantsAdminViewModel.swift
//  
//
//  Created by Ehsan Zilaei on 2022-09-22.
//

import Foundation
import Combine
import SwiftUI

struct ParticipantsAdminViewModel {
    var service: ParticipantService
    
    func updateParticipants(participantName: String, action: UpdateParticipantAction) {
        switch action {
        case .add:
            service.data.insert(participantName)
        case .remove:
            service.removeParticipant(name: participantName)
        }
        
        Task {
            await service.save()
        }
    }
    
    var participantPublisher: Published<ParticipantServiceType>.Publisher {
        return service.$data
    }
}
