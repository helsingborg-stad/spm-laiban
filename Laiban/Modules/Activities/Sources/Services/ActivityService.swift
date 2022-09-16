//
//  ActivityService.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-06.
//

import Foundation

import SwiftUI
import Combine

public typealias ActivityServiceType = [Activity]
public typealias ActivityStorageService = CodableLocalJSONService<ActivityServiceType>

public class ActivityService: CTS<ActivityServiceType, ActivityStorageService>, LBAdminService, LBTranslatableContentProvider,LBDashboardItem, LBParticipants {
    public struct Rating: Codable, Equatable,Hashable {
        public let reaction:LBFeedbackReaction
        public let date:Date
        public let activity:String
    }
    public let viewIdentity: LBViewIdentity = .activities
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    
    public var stringsToTranslatePublisher: AnyPublisher<[String], Never> {
        return $stringsToTranslate.eraseToAnyPublisher()
    }
    
    @Published public var stringsToTranslate: [String] = []
    
    let ratingSubject = PassthroughSubject<Rating,Never>()
    
    public var ratingPublisher:AnyPublisher<Rating,Never> {
        ratingSubject.eraseToAnyPublisher()
    }
    
    @Published var participantsPublisher: Set<String> = []
    
    public func setParticipantsPublisher(publisher: AnyPublisher<Set<String>, Never>) {
        publisher.sink { [weak self] participants in
            self?.participantsPublisher = participants
        }
        .store(in: &cancellables)
    }
    
    private func handleParticipantsChange() {
        $participantsPublisher
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.syncActivityUsers()
            }
            .store(in: &cancellables)
    }
    
    private func syncActivityUsers() {
        data.indices.forEach { index in
            let intersectResult = participantsPublisher.intersection(data[index].participants)
            
            data[index].participants = intersectResult
        }
        
        Task {
            await save()
        }
    }
    
    private var updateParticipantCallback: ((String, UpdateParticipantAction) -> Void)? = nil
    
    public func setUpdateParticipantCallback(callback: @escaping (String, UpdateParticipantAction) -> Void) {
        self.updateParticipantCallback = callback
    }
    
    public func updateParticipant(participant: String, action: UpdateParticipantAction) {
        self.updateParticipantCallback?(participant, action)
    }
        
    public var id: String = "ActivityService"
    public var listOrderPriority: Int = 1
    public var listViewSection: LBAdminListViewSection = .content
    public var cancellables = Set<AnyCancellable>()
    public var todaysActivities: [Activity] {
        data.filter { activity  in activity.date.today == true }
    }
    public func register(_ reaction: LBFeedbackReaction, to activity:Activity) {
        ratingSubject.send(Rating(reaction: reaction, date: Date(), activity: activity.content))
    }
    
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "Activities", foldername: "ActivityService", bundleFilename:"Activities")
        )
        $data.sink { [weak self] activities in
            var strings = [String]()
            for a in activities {
                let fc = a.formattedContent()
                if fc != a.content {
                    strings.append(a.content)
                }
                strings.append(fc)
                strings.append(a.formattedContentPast())
                strings.append(a.formattedContentFuture())
            }
            self?.stringsToTranslate = strings
        }.store(in: &cancellables)
        
        handleParticipantsChange()
    }
    
    public func adminView() -> AnyView {
        AnyView(ActivityAdminView(service: self))
    }
    
    public func remove(_ item: Activity) {
        data.removeAll { i in item.id == i.id }
    }
    
    public func update(_ item:Activity) {
        guard let index = data.firstIndex(where: { e in e.id == item.id }) else {
            add(item)
            return
        }
        data[index] = item
    }
    
    public func add(_ item:Activity) {
        if contains(item) {
            return
        }
        data.append(item)
        sortActivities()
    }
    
    public func contains(_ item:Activity) -> Bool {
        data.contains(where: { i in i.id == item.id })
    }
    
    public func sortActivities() {
        data.sort { (a1, a2) in a1.date > a2.date }
    }
}
