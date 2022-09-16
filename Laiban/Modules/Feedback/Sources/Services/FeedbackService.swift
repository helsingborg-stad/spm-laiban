//
//  Created by Ehsan Zilaei on 2022-06-30.
//

import Foundation
import SwiftUI
import Combine

public typealias FeedbackServiceType = [FeedbackValue]
public typealias FeedbackStorageService = CodableLocalJSONService<FeedbackServiceType>

public class FeedbackService: CTS<FeedbackServiceType, FeedbackStorageService>, LBAdminService, LBDashboardItem {
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    
    @Published public private(set) var isAvailable: Bool = true
    
    public var id: String = "FeedbackService"
    public var listOrderPriority: Int = 10
    public var listViewSection = LBAdminListViewSection(id: "FeedbackSection", title: "Feedback", listOrderPriority: .information.after)
    
    public func adminView() -> AnyView {
        AnyView(FeedbackAdminView(service: self))
    }
    
    public let viewIdentity: LBViewIdentity = .feedback
    
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "Feedback", foldername: "FeedbackService", bundleFilename:"Feedbacks", bundle:.module))
    }
    
    public func add(reaction: LBFeedbackReaction, category: FeedbackCategory, value: String) -> FeedbackValue {
        if let index = self.data.firstIndex(where: { v in v.value == value && v.date.today }) {
            self.data[index].add(reaction: reaction)
            return self.data[index]
        }
        var val = FeedbackValue(value: value, category: category)
        val.add(reaction: reaction)
        data.append(val)
        return val
    }
    
    public func values(in category: FeedbackCategory) -> [FeedbackValue] {
        return self.data.filter { f in f.category == category && f.value != "" }.reversed()
    }
}
