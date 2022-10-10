import Foundation
import Combine

fileprivate let regex = try! NSRegularExpression(pattern: "(^[ft]{14}$)")

public actor LBAttireSuggestionGarmentProvider : AttireSuggestionGarmentProvider {
    typealias SeasonalBreakPoint = WeatherCondition.SeasonalBreakPoint
    private var dateformatter:DateFormatter
    private var winterStarts:Date
    private var winterEnds:Date
    private var autumnStarts:Date
    private var springEnds:Date
    private var currentYear:Int
    public init() {
        self.dateformatter = DateFormatter()
        self.dateformatter.dateFormat = "yyyy-MM-d"
        
        self.currentYear    = Calendar(identifier: .gregorian).component(.year, from: Date())
        self.winterStarts   = dateformatter.date(from: SeasonalBreakPoint.winterStarts.dateString(year: currentYear))!
        self.winterEnds     = dateformatter.date(from: SeasonalBreakPoint.winterEnds.dateString(year: currentYear))!
        self.autumnStarts   = dateformatter.date(from: SeasonalBreakPoint.autumnStarts.dateString(year: currentYear))!
        self.springEnds     = dateformatter.date(from: SeasonalBreakPoint.springEnds.dateString(year: currentYear))!
    }
    public func getEncodedAttire(date: Date, temperature: Double, precipitation: Double) -> String {
        let condition = WeatherCondition.condition(for: temperature, precipitation: precipitation)
        let garments = self.garments(condition: condition, for: date)
        return Garment.string(from: garments)
    }
    nonisolated public func validate(encodedAttire string:String) throws {
        if !regex.matches(string) {
            throw LocalAttireSuggestionError.attireEntryInvalid(string)
        }
    }
    private func garments(condition:WeatherCondition, for date:Date) -> [Garment] {
        let year = Calendar(identifier: .gregorian).component(.year, from: date)
        if year != currentYear {
            self.currentYear    = year
            self.winterStarts   = dateformatter.date(from: SeasonalBreakPoint.winterStarts.dateString(year: year))!
            self.winterEnds     = dateformatter.date(from: SeasonalBreakPoint.winterEnds.dateString(year: year))!
            self.autumnStarts   = dateformatter.date(from: SeasonalBreakPoint.autumnStarts.dateString(year: year))!
            self.springEnds     = dateformatter.date(from: SeasonalBreakPoint.springEnds.dateString(year: year))!
        }
        return condition.garments(date: date, winterStarts: winterStarts, winterEnds: winterEnds, autumnStarts: autumnStarts, springEnds: springEnds)
    }
}
