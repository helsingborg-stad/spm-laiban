import Foundation
import Combine
import SwiftUI

public typealias ParticipantServiceType = Set<String>
public typealias ParticipantStorageService = CodableLocalJSONService<ParticipantServiceType>

public class ParticipantService: CTS<ParticipantServiceType, ParticipantStorageService>, LBAdminService {
    public var id: String = "ParticipantService"
    
    public var listOrderPriority: Int = 1
    
    public var listViewSection: LBAdminListViewSection = .content
    
    public func adminView() -> AnyView {
        AnyView(Text("Participant admin view placeholder"))
    }
    
    public var getParticipantPublisher: AnyPublisher<Set<String>, Never> {
        return $data.eraseToAnyPublisher()
    }
    
    public func addParticipant(name: String) {
        data.insert(name)
    }
    
    public func removeParticipant(name: String) {
        data.remove(name)
    }
    
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "Participants", foldername: "ParticipantService", bundleFilename:"Participants")
        )
    }
}
