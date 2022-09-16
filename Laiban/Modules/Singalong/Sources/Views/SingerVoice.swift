//
//  Singer2.swift
//
//  Created by Tomas Green on 2020-03-23.
//

import Foundation
import AVFoundation
import Combine
import UIKit
import SwiftUI

class SingerVoice : ObservableObject {
    enum Status {
        case waiting
        case singing
        case error
        case done
    }
    struct Segment {
        var synthesizer = AVSpeechSynthesizer()
        let id = UUID()
        var index:Int
        var string:String
        var rate:Float
        var time:TimeInterval
        var pitch:Float
        init(index:Int, string:String, time:TimeInterval, rate:Float = 0.3, pitch:Float = 0.5) {
            self.index = index
            self.string = string
            self.time = time
            self.pitch = pitch
            self.rate = rate
        }
        func play() {
            let utterance = AVSpeechUtterance(string: self.string)
            utterance.voice = AVSpeechSynthesisVoice(language: "sv")
            utterance.pitchMultiplier = self.pitch
            utterance.rate = self.rate
            utterance.preUtteranceDelay = 0
            utterance.postUtteranceDelay = 0
            utterance.volume = 1
            synthesizer.speak(utterance)
        }
        func stop() {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    var fontSize: CGFloat = 20
    private var index = 0
    private let player = AVQueuePlayer()
    private var segments = [Segment]()
    private var timeObserverToken: Any?
    private(set) var allSegments = [Segment]()
    private(set) var objectWillChange = ObservableObjectPublisher()

    @Published var string = NSAttributedString() {
        didSet {
            self.objectWillChange.send()
        }
    }
    @Published var status:Status = .waiting {
        didSet {
            self.objectWillChange.send()
        }
    }
    @objc private func didFinishPlaying(_ notification: NSNotification) {
        status = .done
    }
    init (fontSize:CGFloat = 18) {
        self.fontSize = fontSize
        allSegments = createLyrics()
        addPeriodicTimeObserver()
    }
    var songFile:URL? {
        return nil
    }
    func play() {
        if status == .singing {
            return
        }
        guard let url = songFile else {
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: "No file to play"))
            return
        }
        segments = allSegments
        let i = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: i)
        player.volume = 0.3
        player.insert(i, after: nil)
        player.play()
    }
    func stop() {
        player.pause()
        player.removeAllItems()
        segments = allSegments
        status = .done
        for segment in allSegments {
            segment.stop()
        }
    }
    func createLyrics() -> [Segment]{
        return []
    }
    private func firstSegmentAfter(delay:TimeInterval) -> Segment? {
        for segment in segments {
            if  delay >= segment.time {
                segments.removeFirst()
                return segment
            }
        }
        return nil
    }
    private func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let t = self?.player.currentItem?.currentTime() else {
                return
            }
            if let segment = self?.firstSegmentAfter(delay: TimeInterval(CMTimeGetSeconds(t))) {
                segment.play()
                self?.updateAttributedString(current: segment)
            }
        }
    }
    private func updateAttributedString(current segment:Segment) {
        self.string = self.createAttributedString(highlight: segment)
    }
    private func createAttributedString(highlight segment:Segment) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = fontSize * 0.6
        style.alignment = .center
        let n = NSMutableAttributedString()
        for s in allSegments {
            if s.id == segment.id {
                n.append(NSAttributedString(string: s.string + " ", attributes: [
                    .foregroundColor:UIColor(named: "SingalongTextColorHighlighted") ?? UIColor.red,
                    .font:highlightedFont
                ]))
                // .underlineStyle: NSUnderlineStyle.single
            } else {
                n.append(NSAttributedString(string: s.string + " ", attributes: [
                    .foregroundColor:UIColor(named: "DefaultTextColor") ?? UIColor.black,
                    .font:regularFont
                ]))
            }
        }
        n.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: n.length))
        return n
    }
    private var regularFont:UIFont {
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: fontSize)
        }
        return systemFont
    }
    private var highlightedFont:UIFont {
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: fontSize)
        }
        return systemFont
    }
}
