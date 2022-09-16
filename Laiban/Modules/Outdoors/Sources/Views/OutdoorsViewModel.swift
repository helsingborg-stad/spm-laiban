//
//  OutdoorsViewModel.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-12.
//

import Combine
import CoreML
import Foundation
import SwiftUI

import Assistant

extension OutdoorsView {
    @MainActor class OutdoorsViewModel: ObservableObject {
        weak var service: OutdoorsService?
        private weak var assistant:Assistant?
        private weak var viewState:LBViewState?
        enum UserActionButton: String, Equatable {
            case rateGood
            case rateBad
            case changeClothes
            case done
            case cancel
        }

        enum FeedbackState: String, Equatable {
            case provideFeedback
            case thanks
            var text: String {
                switch self {
                case .provideFeedback: return "outdoors_feedback_provideFeedback"
                case .thanks: return "outdoors_feedback_thanks"
                }
            }
        }

        enum ViewSection: String, Equatable {
            case clothes
            case changeClothes
        }

        @Published var garments = [Garment]()
        @Published var zoomedGarment:Garment? = nil
        @Published var temperatureString = ""
        @Published var currentWeatherEmoji: String = "🌦"
        @Published var viewSection: ViewSection = .clothes
        @Published var feedbackState: FeedbackState = .provideFeedback
        @Published var didRateBad = false
        @Published var didChange = false
        var cancellables = Set<AnyCancellable>()
        var coremlModel = try? AttireSuggestionPredictionModel(configuration: MLModelConfiguration())
        private var currentTemperature: String = ""

        init(_ service: OutdoorsService) {
            self.service = service
        }
        func initiate(using assistant:Assistant, viewState:LBViewState) {
            self.assistant =  assistant
            self.viewState = viewState
            assistant.$currentlySpeaking.sink { [weak self] utterance in
                self?.zoomedGarment = self?.garments.first(where: { $0.localizationKey == utterance?.tag } )
            }.store(in: &cancellables)
            assistant.$translationBundle.sink { [weak self] _ in
                self?.update()
            }.store(in: &cancellables)
            update()
        }
        
        func update() {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
                currentTemperature = "-10"
                currentWeatherEmoji = "❄️"
                temperatureString = String(format:NSLocalizedString(WeatherCondition.coldAndRainy.localizationKey, comment: ""),currentTemperature)
                garments = WeatherCondition.coldAndRainy.garments
                garments.append(contentsOf: [.winterOutfit ,.neckwear ,.beanie])
                return
            }
            guard let service = service,let assistant = assistant else {
                return
            }
            
            currentWeatherEmoji = service.weather?.symbol.emoji ?? "🌦"
            if let temp = service.weather?.airTemperatureFeelsLike {
                currentTemperature = "\(Int(round(temp)))"
            } else {
                currentTemperature = ""
            }

            garments = []
            var voiceStrings = [(String,String)]()
            let store = service.garmentStore
            if let data = service.weather {
                let garments = store.getGarments(service, coremlModel: coremlModel)
                self.garments = garments
                
                temperatureString = String(format:assistant.string(forKey: data.conditions.localizationKey),currentTemperature)
                
                voiceStrings.append((temperatureString,temperatureString))
                voiceStrings.append((assistant.string(forKey: "outdoors_go_out"),"outdoors_go_out"))
                for g in garments {
                    voiceStrings.append((assistant.string(forKey: g.localizationKey), g.localizationKey))
                }
                voiceStrings.append((assistant.string(forKey: "outdoors_feedback_provideFeedback"),"outdoors_feedback_provideFeedback"))
            }
            assistant.speak(voiceStrings)
        }

        func rate(_ rating: GarmentStore.Rating, tag: GarmentStore.RatingTag) {
            guard let service = service else {
                return
            }
            if let wd = service.weather, let record = service.garmentStore.getRecord(for: wd.conditions) {
                service.garmentStore.rate(rating, tag: tag, record: record)
            } else {
                service.garmentStore.rate(rating, tag: tag, garments: garments)
            }
        }

        func didPressUserAction(button: UserActionButton) {
            guard let assistant = assistant else {
                return
            }
            var sayThanks = false
            switch button {
            case .rateGood:
                rate(.good, tag: .child)
                sayThanks = true
                feedbackState = .thanks
            case .rateBad:
                rate(.bad, tag: .child)
                sayThanks = true
                if !didRateBad {
                    didRateBad = true
                }
                feedbackState = .thanks
            case .changeClothes:
                viewSection = .changeClothes
                assistant.cancelSpeechServices()
            case .done:
                sayThanks = true
                feedbackState = .thanks
                viewSection = .clothes
            case .cancel:
                feedbackState = .provideFeedback
            }
            if sayThanks {
                assistant.speak([(FeedbackState.thanks.text,FeedbackState.thanks.text)]).last?.statusPublisher.sink(receiveValue: { [weak self] status in
                    if status == .finished || status == .cancelled || status == .failed {
                        self?.feedbackState = .provideFeedback
                    }
                }).store(in: &cancellables)
            }
        }

        func reportGarments(_ garments: [Garment]) {
            guard let service = service else {
                return
            }
            var garments = garments
            if garments.contains(.jacket), garments.contains(.pulloverPants) {
                garments.removeAll { $0 == .jacket || $0 == .pulloverPants }
                garments.append(.winterOutfit)
            }
            let store = service.garmentStore
            if let data = service.weather{
                store.addRecord(.init(garments: garments, contitions: data.conditions))
            }
            update()
        }
    }
}
