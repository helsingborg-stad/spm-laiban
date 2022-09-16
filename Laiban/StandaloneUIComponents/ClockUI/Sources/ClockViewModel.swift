import Foundation
import SwiftUI

/// Describes an item to show on the clock face and the horizontal timeline
public struct ClockItem : Hashable, Identifiable {
    /// The id of the item, must be unique, at among a provided array
    public let id:String
    /// An emoji describing the item
    public var emoji:String
    /// The date (or rather the time) of the item
    public var date:Date
    /// Text describing the item
    public var text:String
    /// An optional tag related to the item
    public var tag:String?
    /// Background color of the item circle
    public var color:Color?
    /// Angle in the clockface related the time of the item
    public var angle:Angle {
        ClockAngle.angle(from: date).hour
    }
    /// Instantiates a new Item
    /// - Parameters:
    ///   - id: The id of the item, must be unique, at among a provided array
    ///   - emoji: An emoji describing the item
    ///   - date: The date (or rather the time) of the item
    ///   - text: Text describing the item
    ///   - tag: An optional tag related to the item
    ///   - color: Background color of the item circle
    public init(id:String = UUID().uuidString,emoji:String,date:Date,text:String,tag:String? = nil, color:Color? = nil) {
        self.id = id
        self.emoji = emoji
        self.date = date
        self.text = text
        self.tag = tag
        self.color = color
    }
}
/// View model containing properties for the Clocks
public class ClockViewModel : ObservableObject, Identifiable {
    /// Items to display
    @Published public var items:[ClockItem] = []
    /// Time for when the day starts
    @Published public var dayStarts:String
    /// Time for when the day ends
    @Published public var dayEnds:String
    /// Enable a 24 hour clock, past 12:00 all numbers will change in the span of 13-24
    @Published public var militaryTime = false
    /// Show/Hide the clock hour and minute marks
    @Published public var showClockMarkings = true
    /// Show/Hide the seconds hand
    @Published public var showClockSeconds = true
    /// Show/Hide the hour text on the analogue clock view
    @Published public var showClockHourText = true
    /// Show/Hide items
    @Published public var showItems = true
    /// Show/Hide the timespan for when the day starts and ends
    @Published public var showTimeSpan = true
    /// Show/Hide the clock face shadow
    @Published public var showShadow:Bool = false
    /// Holds the image for the seconds hand. If you wish to replace it, make sure it's perfectly square.
    /// - note: For the coloring to work the image must be a template image.
    @Published public var secondsHandImage:Image
    /// Holds the image for the minutes hand. If you wish to replace it, make sure it's perfectly square.
    /// - note: For the coloring to work the image must be a template image.
    @Published public var minutesHandImage:Image
    /// Holds the image for the hours hand. If you wish to replace it, make sure it's perfectly square.
    /// - note: For the coloring to work the image must be a template image.
    @Published public var hoursHandImage:Image
    /// The color of the seconds hand.
    /// - note: Only works if the `secondsHandImage` is a template image
    @Published public var secondsHandColor:Color
    /// The color of the minutes hand.
    /// - note: Only works if the `minutesHandImage` is a template image
    @Published public var minutesHandColor:Color
    /// The color of the hours hand.
    /// - note: Only works if the `hoursHandImage` is a template image
    @Published public var hoursHandColor:Color
    /// The color of the hours and minutes markings. The minute markings will be of 0.3% opacity of the hours.
    @Published public var markingsColor:Color
    /// The timeline text color.
    @Published public var timeTextColor:Color
    /// The color of the clock face
    @Published public var faceColor:Color
    /// The color if a single items border and the border around the clockface that's "containing" the items
    @Published public var itemBorderColor:Color
    /// Background color of the none-passed time of the timespan circle
    @Published public var timeSpanBackgroundColor:Color
    /// Background color of the passed time in the timespan circle
    @Published public var timeSpanColor:Color
    /// Sets and locks the hands to a specific time.
    @Published public var timeLock:Date? = nil
    /// The label of the start of the day in the horizontal time view
    @Published public var horizontalMorningLabel:String = "Morgon"
    /// The label the current time in the horizontal time view
    @Published public var horizontalNowLabel:String = "Nu"
    /// The label of the end of the day in the horizontal time view
    @Published public var horizontalEveningLabel:String = "Kväll"
    /// Intansiates a new model
    /// - Parameters:
    ///   - bundle: the bundle to use for assets
    ///   - items: the items to show
    ///   - dayStarts: when the day starts
    ///   - dayEnds: when the day ends
    public init(bundle:Bundle? = nil, items:[ClockItem] = [], dayStarts:String = "08:00", dayEnds:String = "17:00") {
        let bundle:Bundle = bundle ?? Bundle.module
        self.items = items
        self.dayStarts = dayStarts
        self.dayEnds = dayEnds
        
        secondsHandImage = Image("ClockSecondsHand", bundle: bundle)
        minutesHandImage = Image("ClockMinutesHand", bundle: bundle)
        hoursHandImage = Image("ClockHoursHand", bundle: bundle)
        secondsHandColor = Color("ClockSecondsHandColor", bundle: bundle)
        minutesHandColor = Color("ClockMinutesHandColor", bundle: bundle)
        hoursHandColor = Color("ClockHoursHandColor", bundle: bundle)
        markingsColor = Color("ClockMarkingsColor", bundle: bundle)
        timeTextColor = Color("ClockTextColor", bundle: bundle)
        faceColor = Color("ClockFaceColor", bundle: bundle)
        itemBorderColor = Color("ClockEmojiBorderColor",bundle: bundle)
        timeSpanBackgroundColor = Color("ClockTimeSpanBackgroundColor",bundle: bundle)
        timeSpanColor = Color("ClockTimeSpanColor",bundle: bundle)
    }
    /// A dummy model used for debug and preview purposes
    static var dummyModel:ClockViewModel {
        let m = ClockViewModel()
        m.showTimeSpan = true
        m.items = [
            .init(id: "1", emoji: "🥞", date: relativeDateFrom(time: "08:00"), text: "Breakfast", color: Color("ClockSecondsHandColor", bundle:Bundle.module)),
            .init(id: "2", emoji: "🍽", date: relativeDateFrom(time: "11:00"), text: "Lunch", color: Color("ClockHoursHandColor", bundle:Bundle.module)),
            .init(id: "3", emoji: "☕️", date: relativeDateFrom(time: "14:00"), text: "Coffee", color: Color("ClockMinutesHandColor", bundle:Bundle.module)),
            //.init(id: "4", emoji: "🦊", date: relativeDateFrom(time: "19:30"), text: "Test", color: Color.orange),
            //.init(id: "5", emoji: "💁", date: relativeDateFrom(time: "03:00"), text: "Test", color: Color.gray)
        ]
        return m
    }
    /// Angle in the clockface related the current time
    var currentAngle:ClockAngle {
        if let d = timeLock {
            return ClockAngle.angle(from: d)
        }
        return ClockAngle.now
    }
}
