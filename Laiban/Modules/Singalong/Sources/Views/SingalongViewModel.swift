//
//  SingalongViewManager.swift
//
//  Created by Tomas Green on 2020-03-23.
//

import Foundation
import Combine
import UIKit
import SwiftUI

import Assistant

class SingalongViewModel: ObservableObject {
    enum Stage {
        case started
        case waiting
        case singing
        case done
    }
    weak var assistant:Assistant?
    @ObservedObject var singer = TwinkleSong(fontSize: 30)
    @Published var text = "singalong_started"
    @Published var currentText = NSAttributedString(string: "")
    @Published var completedStages = [Stage.started]
    @Published var enabled:Bool = true
    var cancellables = Set<AnyCancellable>()
    var obs:AnyCancellable?
    var shouldEnable:Bool {
        if LBDevice.isSimulator {
            return true
        }
        if Date() >= relativeDateFrom(time: "10:30") && Date() <= relativeDateFrom(time: "11:30") {
            return true
        }
        if Date() >= relativeDateFrom(time: "13:30") && Date() <= relativeDateFrom(time: "14:30") {
            return true
        }
        return false
    }
    func initiate(using assistant:Assistant) {
        self.assistant = assistant
        enabled = shouldEnable
        if enabled == false {
            text = "singalong_time_deactivated"
        } else {
            text = "singalong_started"
            resetSinger()
        }
        speak()
    }
    func speak() {
        assistant?.speak(text).last?.statusPublisher.sink(receiveValue: { [weak self] status in
            self?.completedStages.append(.waiting)
        }).store(in: &cancellables)
    }
    func setFontSize(_ size:CGFloat) {
        singer.fontSize = size
    }
    func resetSinger() {
        singer = TwinkleSong(fontSize: 30)
        obs?.cancel()
        obs = singer.objectWillChange.sink(receiveValue: { [weak self] in
            guard let this = self else {
                return
            }
            this.currentText = this.singer.string
            if this.singer.status == .done {
                this.completedStages.append(.done)
                this.text = "singalong_repeat"
                this.speak()
            }
        })
    }
    func play() {
        if !enabled {
            return
        }
        assistant?.cancelSpeechServices()
        if completedStages.contains(.done) {
            resetSinger()
            completedStages = [.started,.waiting]
        }
        if completedStages.contains(.singing) || singer.status == .singing {
            return
        }
        completedStages.append(.singing)
        singer.play()
    }
}
