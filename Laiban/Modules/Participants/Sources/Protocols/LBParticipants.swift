import Foundation
import Combine

public enum UpdateParticipantAction {
    case add, remove
}

public protocol LBParticipants {
    func setUpdateParticipantCallback(callback: @escaping (String, UpdateParticipantAction) -> Void)
    func updateParticipant(participant: String, action: UpdateParticipantAction)
    func setParticipantsPublisher(publisher: AnyPublisher<Set<String>, Never>)
}
