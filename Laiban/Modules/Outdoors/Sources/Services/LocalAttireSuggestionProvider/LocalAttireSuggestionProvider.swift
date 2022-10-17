import Foundation
import Weather

fileprivate let regex = try! NSRegularExpression(pattern: #"\W"#)

public enum LocalAttireSuggestionError : Error {
    case noResult
    case platformNotSupported
    case missingDefaultTrainingData
    case missingMlModel
    case notEnoughDataToTrain
    case temperatureEntryInvalid(Double)
    case humidityEntryInvalid(Double)
    case dewPointEntryInvalid(Double)
    case windSpeedEntryInvalid(Double)
    case windGustSpeedEntryInvalid(Double)
    case windDirectionEntryInvalid(Double)
    case airPressureEntryInvalid(Double)
    case totalPrecipitationEntryInvalid(Double)
    case attireEntryInvalid(String)
}

public protocol AttireSuggestionGarmentProvider {
    func getEncodedAttire(date:Date, temperature:Double, precipitation:Double) async -> String
    func validate(encodedAttire:String) throws
}
public protocol LocalAttireSuggestionDataProvider {
    func generateData(writeCSVTo url:URL) async throws
}

#if canImport(CreateMLComponents) && canImport(TabularData)
import CreateMLComponents
import TabularData
#endif

/// `LocalAttireSuggestionProvider` uses a tablular classficication model to train and predict what types of clothes once should wear depending on a number of weather parameters
public actor LocalAttireSuggestionProvider {
    /// Clothes predction results
    public struct Results {
        /// Encoded list of garments,, see `Garment` for more information
        public let attire:String
        /// The probability/accuracy of the prediction in % (0-1)
        public let probability:Double
    }
    public struct UpdateEntry : Codable {
        public let temperature:Double
        public let humidity:Double
        public let dewPoint:Double
        public let windSpeed:Double
        public let windGustSpeed:Double
        public let windDirection:Double
        public let airPressure:Double
        public let totalPrecipitation:Double
        public let attire:String

        public init (
            temperature:Double,
            humidity:Double,
            dewPoint:Double,
            windSpeed:Double,
            windGustSpeed:Double,
            windDirection:Double,
            airPressure:Double,
            totalPrecipitation:Double,
            attire:String
        ) {
            self.temperature = temperature
            self.humidity = humidity
            self.dewPoint = dewPoint
            self.windSpeed = windSpeed
            self.windGustSpeed = windGustSpeed
            self.windDirection = windDirection
            self.airPressure = airPressure
            self.totalPrecipitation = totalPrecipitation
            self.attire = attire
        }
        
        public func validate(using provider:AttireSuggestionGarmentProvider) throws {
            if temperature < -273.15 {
                throw LocalAttireSuggestionError.temperatureEntryInvalid(temperature)
            }
            if humidity < 0 || humidity > 100{
                throw LocalAttireSuggestionError.humidityEntryInvalid(humidity)
            }
            if dewPoint < -273.15 {
                throw LocalAttireSuggestionError.dewPointEntryInvalid(dewPoint)
            }
            if windSpeed < 0 {
                throw LocalAttireSuggestionError.windSpeedEntryInvalid(windSpeed)
            }
            if windGustSpeed < 0 {
                throw LocalAttireSuggestionError.windGustSpeedEntryInvalid(windGustSpeed)
            }
            if windDirection > 360 || windDirection < -360 {
                throw LocalAttireSuggestionError.windDirectionEntryInvalid(windDirection)
            }
            if airPressure < 0 {
                throw LocalAttireSuggestionError.airPressureEntryInvalid(airPressure)
            }
            if totalPrecipitation < 0 {
                throw LocalAttireSuggestionError.totalPrecipitationEntryInvalid(totalPrecipitation)
            }
            try provider.validate(encodedAttire: attire)
        }
    }
    let defaultDataURL:URL?
    let dataURL:URL
    let modelURL:URL
    let labelsURL:URL
    let garmentProvider:AttireSuggestionGarmentProvider
    /// Initializes a new `LocalAttireSuggestionGenerator`
    /// - Parameters:
    ///   - defaultDataURL: Default data provided, default value is `Bundle.main.url(forResource: "data", withExtension: "csv")`
    ///   - libraryFolderName: App library folder name, only word characters and no spaces, defautls to `"LocalAttireSuggestions"`
    public init(defaultDataURL:URL? = Bundle.main.url(forResource: "data", withExtension: "csv"), libraryFolderName:String = "LocalAttireSuggestions", garmentProvider:AttireSuggestionGarmentProvider) {
        var libraryFolderName = libraryFolderName
        if regex.matches(libraryFolderName) {
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + "libraryFolderName not valid, using default instead")
            libraryFolderName = "LocalAttireSuggestions"
        }
        self.garmentProvider = garmentProvider
        self.defaultDataURL = defaultDataURL
        let storageDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent(libraryFolderName)
        
        if FileManager.default.fileExists(atPath: storageDirectory.path) == false {
            do {
                try FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey: FileProtectionType.complete])
            } catch {
                fatalError("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
            }
        }
        dataURL = storageDirectory.appendingPathComponent("TrainingData.csv")
        modelURL = storageDirectory.appendingPathComponent("AttireSuggestorModel.pkg")
        labelsURL = storageDirectory.appendingPathComponent("Labels.json")
    }
    
    /// Indicates whether or not the generator is supported on the speciic platform.
    /// Unsupported platforms are:
    /// - iOS/iPadOS before 16
    /// - macOS before 13 (including iOS 16 simluators runing on macOS 12)
    public static var isSupported:Bool {
        var res:Bool = true
        #if canImport(CreateMLComponents) && canImport(TabularData)
        res = true
        #else
        res = false
        #endif
        return res
    }
    
    /// Indicates whether or not the generator requires precition model training
    public var requiresTraining:Bool {
        return !FileManager.default.fileExists(atPath: modelURL.path) || !FileManager.default.fileExists(atPath: labelsURL.path)
    }
    
    #if canImport(CreateMLComponents) && canImport(TabularData)
    static let classifierColumn = ColumnID(DataColumn.attire.rawValue, String.self)
    public enum DataColumn: String, CaseIterable {
        case temperature
        case humidity
        case dewPoint
        case windSpeed
        case windGustSpeed
        case windDirection
        case airPressure
        case totalPrecipitation
        case attire
        var csvType:CSVType {
            switch self {
            case .attire: return .string
            default: return .double
            }
        }
        static var csvTypes:[String : CSVType] {
            var dict = [String : CSVType]()
            for a in allCases {
                dict[a.rawValue] = a.csvType
            }
            return dict
        }
        static var featureColumns:[String] {
            var cols = allCases
            cols.removeLast()
            return cols.map { $0.rawValue }
        }
        static var columns:[String] {
            allCases.map { $0.rawValue }
        }
    }
    
    private func task(with labels:Set<String>) -> some SupervisedTabularEstimator {
        return BoostedTreeClassifier(labels: labels, annotationColumnName: DataColumn.attire.rawValue, featureColumnNames: DataColumn.featureColumns)
    }
    
    private func getDataFrame() throws -> DataFrame {
        if FileManager.default.fileExists(atPath: dataURL.path) {
            return try DataFrame(contentsOfCSVFile: dataURL, columns: DataColumn.columns,types: DataColumn.csvTypes)
        }
        guard let defaultDataURL else {
            throw LocalAttireSuggestionError.missingDefaultTrainingData
        }
        let frame = try DataFrame(contentsOfCSVFile: defaultDataURL, columns: DataColumn.columns,types: DataColumn.csvTypes)
        try frame.writeCSV(to: dataURL)
        return frame
    }
    
    private func _train(using dataFrame:DataFrame) async throws {
        let col = dataFrame[Self.classifierColumn]
        var labels = Set<String>()
        for a in col.distinct() {
            guard let val = a else {
                continue
            }
            labels.insert(val)
        }
        try JSONEncoder().encode(labels).write(to: labelsURL)
        if labels.count < 3 {
            throw LocalAttireSuggestionError.notEnoughDataToTrain
        }
        //MARK: Train model
        let task = task(with: labels)
        let (training, validation) = dataFrame.randomSplit(by: 0.8)
        let transformer = try await task.fitted(to: DataFrame(training), validateOn: DataFrame(validation)) { event in
            guard let validationError = event.metrics[.validationError] as? Double else {
                return
            }
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: validationError))
        }
        try task.write(transformer, to: modelURL)
    }
    private func createDataFrame(using entries:[UpdateEntry]) -> DataFrame {
        return [
            DataColumn.temperature.rawValue:        entries.map{ $0.temperature },
            DataColumn.humidity.rawValue:           entries.map{ $0.humidity },
            DataColumn.dewPoint.rawValue:           entries.map{ $0.dewPoint },
            DataColumn.windSpeed.rawValue:          entries.map{ $0.windSpeed },
            DataColumn.windGustSpeed.rawValue:      entries.map{ $0.windGustSpeed },
            DataColumn.windDirection.rawValue:      entries.map{ $0.windDirection },
            DataColumn.airPressure.rawValue:        entries.map{ $0.airPressure },
            DataColumn.totalPrecipitation.rawValue: entries.map{ $0.totalPrecipitation },
            DataColumn.attire.rawValue:            entries.map{ $0.attire }
        ]
    }
    
    private func _update(using entries:[UpdateEntry], trainAfterUpdate:Bool = true) async throws {
        for e in entries {
            try e.validate(using: garmentProvider)
        }
        var dataFrame:DataFrame
        do {
            dataFrame = try getDataFrame()
            for entry in entries {
                dataFrame.append(valuesByColumn: [
                    DataColumn.temperature.rawValue:        entry.temperature,
                    DataColumn.humidity.rawValue:           entry.humidity,
                    DataColumn.dewPoint.rawValue:           entry.dewPoint,
                    DataColumn.windSpeed.rawValue:          entry.windSpeed,
                    DataColumn.windGustSpeed.rawValue:      entry.windGustSpeed,
                    DataColumn.windDirection.rawValue:      entry.windDirection,
                    DataColumn.airPressure.rawValue:        entry.airPressure,
                    DataColumn.totalPrecipitation.rawValue: entry.totalPrecipitation,
                    DataColumn.attire.rawValue:            entry.attire
                ])
            }
        } catch {
            dataFrame = createDataFrame(using: entries)
        }
        try dataFrame.writeCSV(to: dataURL)
        if trainAfterUpdate {
            try await _train(using: dataFrame)
        }
    }
    private func _resetTrainingData(using entries:[UpdateEntry], trainAfterUpdate:Bool = true) async throws {
        deleteContent()
        for e in entries {
            try e.validate(using: garmentProvider)
        }
        let dataFrame:DataFrame = createDataFrame(using: entries)
        try dataFrame.writeCSV(to: dataURL)
        if trainAfterUpdate {
            try await _train(using: dataFrame)
        }
    }
    private func _resetTrainingDataToDefaults() throws {
        guard let defaultDataURL else {
            throw LocalAttireSuggestionError.missingDefaultTrainingData
        }
        let frame = try DataFrame(contentsOfCSVFile: defaultDataURL, columns: DataColumn.columns,types: DataColumn.csvTypes)
        try frame.writeCSV(to: dataURL)
    }
    
    private func _resetTrainingDataUsing(provider:LocalAttireSuggestionDataProvider) async throws {
        try await provider.generateData(writeCSVTo: dataURL)
    }
    
    private func _train() async throws {
        let dataFrame = try getDataFrame()
        if FileManager.default.fileExists(atPath: modelURL.path) {
            try dataFrame.writeCSV(to: dataURL)
        }
        try await _train(using: dataFrame)
    }
    
    private func _predict(temperature:Double, humidity:Double, dewPoint:Double, windSpeed:Double, windGustSpeed:Double, windDirection:Double, airPressure:Double, totalPrecipitation:Double) async throws -> [Results] {
        if requiresTraining {
            throw LocalAttireSuggestionError.missingMlModel
        }
        let labels = try JSONDecoder().decode(Set<String>.self, from: try Data(contentsOf: labelsURL))
        let model = try task(with: labels).read(from: modelURL)
        let dataFrame: DataFrame = [
            DataColumn.temperature.rawValue:        [temperature],
            DataColumn.humidity.rawValue:           [humidity],
            DataColumn.dewPoint.rawValue:           [dewPoint],
            DataColumn.windSpeed.rawValue:          [windSpeed],
            DataColumn.windGustSpeed.rawValue:      [windGustSpeed],
            DataColumn.windDirection.rawValue:      [windDirection],
            DataColumn.airPressure.rawValue:        [airPressure],
            DataColumn.totalPrecipitation.rawValue: [totalPrecipitation]
        ]
        let result = try await model(dataFrame)
        guard let val = result["\(DataColumn.attire.rawValue)Probability"][0] as? CreateMLComponents.ClassificationDistribution<String> else {
            throw LocalAttireSuggestionError.noResult
        }
        return val.map { Results(attire: $0.label, probability: Double($0.probability)) }
    }
    #endif
    
    public func deleteContent() {
        try? FileManager.default.removeItem(at: dataURL)
        try? FileManager.default.removeItem(at: labelsURL)
        try? FileManager.default.removeItem(at: modelURL)
    }
    /// Update the prediction model using custom entries.
    /// - Parameter entries: entries with weather and clothes
    /// - Parameter trainAfterUpdate: train model after update
    public func update(using entries:[UpdateEntry], trainAfterUpdate:Bool = true) async throws {
        #if canImport(CreateMLComponents) && canImport(TabularData)
        try await _update(using: entries, trainAfterUpdate:trainAfterUpdate)
        #else
        throw LocalAttireSuggestionError.platformNotSupported
        #endif
    }
    
    /// Reset the prediction model data using default data
    public func resetTrainingDataToDefaults() throws {
        #if canImport(CreateMLComponents) && canImport(TabularData)
        try _resetTrainingDataToDefaults()
        #else
        throw LocalAttireSuggestionError.platformNotSupported
        #endif
    }
    public func resetTrainingData(using entries:[UpdateEntry], trainAfterUpdate:Bool = true) async throws {
        #if canImport(CreateMLComponents) && canImport(TabularData)
        try await _resetTrainingData(using: entries, trainAfterUpdate:trainAfterUpdate)
        #else
        throw LocalAttireSuggestionError.platformNotSupported
        #endif
    }
    /// Reset the prediction model using data from SMHI weather service using latitude and longitude
    public func resetTrainingDataUsing(provider:LocalAttireSuggestionDataProvider) async throws {
        #if canImport(CreateMLComponents) && canImport(TabularData)
        try await _resetTrainingDataUsing(provider: provider)
        #else
        throw LocalAttireSuggestionError.platformNotSupported
        #endif
    }
    
    /// Train using the latest data provided, either locally or from default file
    public func train() async throws {
        #if canImport(CreateMLComponents) && canImport(TabularData)
        try await _train()
        #else
        throw LocalAttireSuggestionError.platformNotSupported
        #endif
    }
    
    /// Predict what kind of clothes once should wear based on the provided paramerters
    /// - Parameters:
    ///   - temperature: the temperature in celcius°
    ///   - humidity: humidity, from 0 to 100
    ///   - dewPoint: dewpoint in celcius°
    ///   - windSpeed: windspeed in meters per second
    ///   - windGustSpeed: windGustSpeed in meters per second
    ///   - windDirection: windDirection in degrees
    ///   - airPressure: air pressure in mbar
    ///   - totalPrecipitation:  mm/h
    /// - Returns: prediction results
    public func predict(temperature:Double, humidity:Double, dewPoint:Double, windSpeed:Double, windGustSpeed:Double, windDirection:Double, airPressure:Double, totalPrecipitation:Double) async throws -> [Results] {
        #if canImport(CreateMLComponents) && canImport(TabularData)
        try await _predict(temperature: temperature, humidity: humidity, dewPoint: dewPoint, windSpeed: windSpeed, windGustSpeed: windGustSpeed, windDirection: windDirection, airPressure: airPressure, totalPrecipitation: totalPrecipitation)
        #else
        throw LocalAttireSuggestionError.platformNotSupported
        #endif
    }
}
