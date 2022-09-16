//
//  TwinkleSong.swift
//
//  Created by Tomas Green on 2020-09-10.
//

import Foundation

class TwinkleSong : SingerVoice {
    override var songFile: URL? {
        guard let path = Bundle.module.path(forResource: "twinkle5", ofType: "m4a") else {
            print("errpr opening file")
            return nil
        }
        return URL(fileURLWithPath: path)
    }
    override func createLyrics() -> [Segment] {
        var index = 0
        var segments = [Segment]()
        func add(_ string:String, after:TimeInterval, rate:Float = 0.3, pitch:Float = 0.5) -> TimeInterval {
            segments.append(Segment(index:index, string: string,  time: after, rate:rate, pitch:pitch))
            index += 1
            return after
        }
        var time:TimeInterval = 0
        let pitch:Float = 0.7
        time = add("Tvätta,",  after: time + 0.3, rate: 0.3, pitch: pitch + 0.0)
        time = add("tvätta",   after: time + 1.1, rate: 0.3, pitch: pitch + 0.1)
        time = add("liten",    after: time + 1.3, rate: 0.3, pitch: pitch + 0.2)
        time = add("hand\n",   after: time + 1.2, rate: 0.3, pitch: pitch + 0.1)
        time = add("Bort",     after: time + 1.4, rate: 0.3, pitch: pitch + 0.0)
        time = add("med",      after: time + 0.7, rate: 0.3, pitch: pitch + 0.0)
        time = add("smuts",    after: time + 0.4, rate: 0.3, pitch: pitch - 0.1)
        time = add("och",      after: time + 0.8, rate: 0.3, pitch: pitch - 0.1)
        time = add("bort",     after: time + 0.5, rate: 0.3, pitch: pitch - 0.2)
        time = add("med",      after: time + 0.6, rate: 0.3, pitch: pitch - 0.2)
        time = add("sand\n",   after: time + 0.6, rate: 0.3, pitch: pitch - 0.3)
        time = add("Mellan,",  after: time + 1.3, rate: 0.3, pitch: pitch + 0.0)
        time = add("i",        after: time + 1.3, rate: 0.3, pitch: pitch - 0.1)
        time = add("och",      after: time + 0.8, rate: 0.3, pitch: pitch - 0.1)
        time = add("ovanpå\n", after: time + 1.1, rate: 0.3, pitch: pitch - 0.2)
        time = add("Gnugga",   after: time + 1.7, rate: 0.3, pitch: pitch - 0.0)
        time = add("tummen,",  after: time + 1.3, rate: 0.3, pitch: pitch - 0.1)
        time = add("båda",     after: time + 1.4, rate: 0.3, pitch: pitch - 0.1)
        time = add("två\n",    after: time + 1.1, rate: 0.3, pitch: pitch - 0.2)
        time = add("Tvätta,",  after: time + 1.4, rate: 0.3, pitch: pitch + 0.0)
        time = add("tvätta",   after: time + 1.1, rate: 0.3, pitch: pitch + 0.1)
        time = add("liten",    after: time + 1.3, rate: 0.3, pitch: pitch + 0.2)
        time = add("hand\n",   after: time + 1.2, rate: 0.3, pitch: pitch + 0.1)
        time = add("Bort",     after: time + 1.4, rate: 0.3, pitch: pitch + 0.0)
        time = add("med",      after: time + 0.7, rate: 0.3, pitch: pitch + 0.0)
        time = add("smuts",    after: time + 0.4, rate: 0.3, pitch: pitch - 0.1)
        time = add("och",      after: time + 0.8, rate: 0.3, pitch: pitch - 0.1)
        time = add("bort",     after: time + 0.5, rate: 0.3, pitch: pitch - 0.2)
        time = add("med",      after: time + 0.6, rate: 0.3, pitch: pitch - 0.2)
        time = add("sand",     after: time + 0.6, rate: 0.3, pitch: pitch - 0.3)
        return segments
    }
}


