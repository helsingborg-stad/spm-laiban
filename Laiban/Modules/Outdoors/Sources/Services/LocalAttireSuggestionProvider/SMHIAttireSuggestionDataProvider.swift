import Foundation
import Combine
import Weather
#if canImport(CreateMLComponents) && canImport(TabularData)
import TabularData
#endif

public enum SMHIAttireSuggestionDataProviderError: Error {
    case latitudeMissing
    case longitudeMissing
    case periodMissing
    case garmentProviderMissing
    case unsupportedPlatform
}
@available(iOS 16, macOS 13.0, *) public actor SMHIAttireSuggestionDataProvider : LocalAttireSuggestionDataProvider {
    public private(set) var latitude:Double? = nil
    public private(set) var longitude:Double? = nil
    public private(set) var period:String? = nil
    public private(set) var garmentProvider:AttireSuggestionGarmentProvider? = nil
    private var cancellables = Set<AnyCancellable>()

    public init(latitude:Double?, longitude:Double?, period:String?, garmentProvider:AttireSuggestionGarmentProvider?) {
        self.latitude = latitude
        self.longitude = longitude
        self.period = period
        self.garmentProvider = garmentProvider
    }
    public func update(latitude:Double?, longitude:Double?, period:String?, garmentProvider:AttireSuggestionGarmentProvider?) {
        self.latitude = latitude
        self.longitude = longitude
        self.period = period
        self.garmentProvider = garmentProvider
    }
    private func makeAsync<T:Any>(_ publisher:AnyPublisher<T,Error>) async throws -> T  {
        return try await withCheckedThrowingContinuation { continuation in
            publisher.sink { compl in
                if case let .failure(err) = compl {
                    continuation.resume(throwing: err)
                }
            } receiveValue: { val in
                continuation.resume(returning: val)
            }.store(in: &cancellables)
        }
    }
    #if canImport(CreateMLComponents) && canImport(TabularData)
    private func createFrame(with values:SMHIObservations.Value, for property:String) -> DataFrame {
        let vals = values.value.filter { Double($0.value) != nil }
        return [
            "date": vals.map{ $0.date },
            "\(property)": vals.map{ Double($0.value) },
        ]
    }
    #endif
    public func generateData(writeCSVTo url: URL) async throws {
        #if canImport(CreateMLComponents) && canImport(TabularData)
        typealias DataColumn = LocalAttireSuggestionProvider.DataColumn
        guard let latitude else {
            throw SMHIAttireSuggestionDataProviderError.latitudeMissing
        }
        guard let longitude else {
            throw SMHIAttireSuggestionDataProviderError.longitudeMissing
        }
        guard let period else {
            throw SMHIAttireSuggestionDataProviderError.periodMissing
        }
        guard let garmentProvider else {
            throw SMHIAttireSuggestionDataProviderError.garmentProviderMissing
        }
        async let temperature         = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "1",  period: period))
        async let windGustSpeed       = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "21", period: period))
        async let windSpeed           = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "4",  period: period))
        async let airPressure         = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "9",  period: period))
        async let humidity            = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "6",  period: period))
        async let dewPoint            = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "39", period: period))
        async let windDirection       = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "3",  period: period))
        async let totalPrecipitation  = makeAsync(SMHIObservations.publisher(latitude: latitude, longitude: longitude, parameter: "7",  period: period))
        
        let temperatureFrame          = createFrame(with: try await temperature,        for: DataColumn.temperature.rawValue)
        let windGustSpeedFrame        = createFrame(with: try await windGustSpeed,      for: DataColumn.windGustSpeed.rawValue)
        let windSpeedFrame            = createFrame(with: try await windSpeed,          for: DataColumn.windSpeed.rawValue)
        let airPressureFrame          = createFrame(with: try await airPressure,        for: DataColumn.airPressure.rawValue)
        let humidityFrame             = createFrame(with: try await humidity,           for: DataColumn.humidity.rawValue)
        let dewPointFrame             = createFrame(with: try await dewPoint,           for: DataColumn.dewPoint.rawValue)
        let windDirectionFrame        = createFrame(with: try await windDirection,      for: DataColumn.windDirection.rawValue)
        let totalPrecipitationFrame   = createFrame(with: try await totalPrecipitation, for: DataColumn.totalPrecipitation.rawValue)
        
        var frame:DataFrame = temperatureFrame
        
        frame = frame.joined(windGustSpeedFrame,        on: "date", kind: .left)
        frame = frame.joined(windSpeedFrame,            on: "date", kind: .left)
        frame = frame.joined(airPressureFrame,          on: "date", kind: .left)
        frame = frame.joined(humidityFrame,             on: "date", kind: .left)
        frame = frame.joined(dewPointFrame,             on: "date", kind: .left)
        frame = frame.joined(windDirectionFrame,        on: "date", kind: .left)
        frame = frame.joined(totalPrecipitationFrame,   on: "date", kind: .left)
        
        for c in frame.columns {
            frame.renameColumn(c.name, to: String(c.name.split(separator: ".").last!))
        }

        var garmentDict = [Date:String]()
        for row in frame.rows {
            guard let t = row[DataColumn.temperature.rawValue] as? Double else {
                continue
            }
            guard let p = row[DataColumn.totalPrecipitation.rawValue] as? Double  else {
                continue
            }
            guard let d = row["date"] as? Date else {
                continue
            }
            garmentDict[d] = await garmentProvider.getEncodedAttire(date: d, temperature: t, precipitation: p)
        }
        let garmentFrame:DataFrame = [
            "date": garmentDict.map{ $0.key },
            DataColumn.attire.rawValue: garmentDict.map{ $0.value },
        ]
        frame = frame.joined(garmentFrame, on: "date", kind: .left)
        for c in frame.columns {
            frame.renameColumn(c.name, to: String(c.name.split(separator: ".").last!))
        }
        let slice = frame.filter {
            $0.contains { $0 == nil } != true
        }
        frame = DataFrame(slice)
        try frame.writeCSV(to: url)
        #else
        throw SMHIAttireSuggestionDataProviderError.unsupportedPlatform
        #endif
    }
}
