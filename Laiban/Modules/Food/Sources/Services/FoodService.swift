//
//  FoodService.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-06.
//

import Foundation
import Meals
import Shout
import SwiftUI
import Combine

public typealias FoodProcessingStorageService = CodableLocalJSONService<FoodServiceModel>

public class FoodService: CTS<FoodServiceModel, FoodProcessingStorageService>, LBAdminService, LBTranslatableContentProvider,LBDashboardItem {
    public struct Rating: Codable, Equatable,Hashable {
        public let reaction:LBFeedbackReaction
        public let date:Date
        public let food:String
    }
    public struct Statistics: Codable, Equatable,Hashable {
        public var rating1:Int
        public var rating2:Int
        public var rating3:Int
        public var rating4:Int
        public var food:String
        var total:Double {
            return Double(rating1 + rating2 + rating3 + rating4)
        }
        var rating1Proc:Double {
            Double(rating1)/total
        }
        var rating2Proc:Double {
            Double(rating2)/total
        }
        var rating3Proc:Double {
            Double(rating3)/total
        }
        var rating4Proc:Double {
            Double(rating4)/total
        }
        public init(rating1:Int = 0,rating2:Int = 0,rating3:Int = 0,rating4:Int = 0,food:String) {
            self.rating1 = rating1
            self.rating2 = rating2
            self.rating3 = rating3
            self.rating4 = rating4
            self.food = food
        }
    }
    let ratingSubject = PassthroughSubject<Rating,Never>()
    let statisticsSubject = CurrentValueSubject<Statistics?,Never>(nil)
    
    public let viewIdentity: LBViewIdentity = .food
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    public var ratingPublisher:AnyPublisher<Rating,Never> {
        ratingSubject.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = false
    public var id: String = "FoodService"
    public var listViewSection: LBAdminListViewSection = .init(id: "Food", title: "Matsedel", listOrderPriority: .content.after)
    public var listOrderPriority: Int = 1
    public var cancellables = Set<AnyCancellable>()
    public var mealsService = Meals(service: nil, previewData: ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil)
    private var currentMeals = [Meal]()
    public var stringsToTranslatePublisher: AnyPublisher<[String], Never> {
        $stringsToTranslate.eraseToAnyPublisher()
    }
    @Published public private(set) var stringsToTranslate: [String] = []
    @Published public var foodStrings:[String]? = nil
    
    public func adminView() -> AnyView {
        AnyView(FoodAdminView(service: self))
    }
    public func setStaistics(_ statistics: Statistics) {
        statisticsSubject.send(statistics)
    }
    public func register(_ reaction: LBFeedbackReaction) {
        if currentMeals.isEmpty {
            return
        }
        ratingSubject.send(Rating(reaction: reaction, date: Date(), food: currentMeals.map { $0.description }.joined(separator: "\n")))
    }
    public convenience init() {
        self.init(
            emptyValue: FoodServiceModel(),
            storageOptions: .init(filename: "FoodModel", foldername: "FoodService", bundleFilename: "FoodProcessingMethod")
        )
        
        self.$data.sink { model in
            self.mealsService.service = model.foodLink
            self.isAvailable = model.foodLink != nil && model.showOnDashboard
            // makes sure that the translation script is triggered
            if model.foodProcessingMethod != self.data.foodProcessingMethod {
                self.mealsService.fetch(force: true)
            }
        }.store(in: &cancellables)
        self.mealsService.publisher().sink { [weak self] dailyMeals in
            guard let this = self else {
                return
            }
            guard let dailyMeals = dailyMeals else {
                this.foodStrings = nil
                this.currentMeals = []
                return
            }
            this.currentMeals = dailyMeals
            var p:AnyCancellable?
            let fpm = this.data.foodProcessingMethod
            p = fpm.process(dailyMeals.compactMap({$0.description})).receive(on: DispatchQueue.main).sink(receiveValue: { strings in
                let processed = strings.map({ $0.processed})
                this.foodStrings = Array(Set(processed))
                if let p = p {
                    this.cancellables.remove(p)
                }
                this.stringsToTranslate = processed
            })
            if let p = p {
                this.cancellables.insert(p)
            }
        }.store(in: &cancellables)
    }
}
