//
// AttireSuggestionPredictionModel.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class AttireSuggestionPredictionModelInput : MLFeatureProvider {

    /// temperature as double value
    var temperature: Double

    /// humidity as double value
    var humidity: Double

    /// dewPoint as double value
    var dewPoint: Double

    /// windSpeed as double value
    var windSpeed: Double

    /// windGustSpeed as double value
    var windGustSpeed: Double

    /// windDirection as double value
    var windDirection: Double

    /// airPressure as double value
    var airPressure: Double

    /// totalPrecipitation as double value
    var totalPrecipitation: Double

    var featureNames: Set<String> {
        get {
            return ["temperature", "humidity", "dewPoint", "windSpeed", "windGustSpeed", "windDirection", "airPressure", "totalPrecipitation"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "temperature") {
            return MLFeatureValue(double: temperature)
        }
        if (featureName == "humidity") {
            return MLFeatureValue(double: humidity)
        }
        if (featureName == "dewPoint") {
            return MLFeatureValue(double: dewPoint)
        }
        if (featureName == "windSpeed") {
            return MLFeatureValue(double: windSpeed)
        }
        if (featureName == "windGustSpeed") {
            return MLFeatureValue(double: windGustSpeed)
        }
        if (featureName == "windDirection") {
            return MLFeatureValue(double: windDirection)
        }
        if (featureName == "airPressure") {
            return MLFeatureValue(double: airPressure)
        }
        if (featureName == "totalPrecipitation") {
            return MLFeatureValue(double: totalPrecipitation)
        }
        return nil
    }
    
    init(temperature: Double, humidity: Double, dewPoint: Double, windSpeed: Double, windGustSpeed: Double, windDirection: Double, airPressure: Double, totalPrecipitation: Double) {
        self.temperature = temperature
        self.humidity = humidity
        self.dewPoint = dewPoint
        self.windSpeed = windSpeed
        self.windGustSpeed = windGustSpeed
        self.windDirection = windDirection
        self.airPressure = airPressure
        self.totalPrecipitation = totalPrecipitation
    }

}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class AttireSuggestionPredictionModelOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// clothes as string value
    lazy var clothes: String = {
        [unowned self] in return self.provider.featureValue(for: "clothes")!.stringValue
    }()

    /// clothesProbability as dictionary of strings to doubles
    lazy var clothesProbability: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "clothesProbability")!.dictionaryValue as! [String : Double]
    }()

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(clothes: String, clothesProbability: [String : Double]) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["clothes" : MLFeatureValue(string: clothes), "clothesProbability" : MLFeatureValue(dictionary: clothesProbability as [AnyHashable : NSNumber])])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class AttireSuggestionPredictionModel {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle.module
        return bundle.url(forResource: "AttireSuggestionPredictionModel", withExtension:"mlmodelc")!
    }

    /**
        Construct AttireSuggestionPredictionModel instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of AttireSuggestionPredictionModel.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `AttireSuggestionPredictionModel.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct AttireSuggestionPredictionModel instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct AttireSuggestionPredictionModel instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct AttireSuggestionPredictionModel instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<AttireSuggestionPredictionModel, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct AttireSuggestionPredictionModel instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> AttireSuggestionPredictionModel {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct AttireSuggestionPredictionModel instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<AttireSuggestionPredictionModel, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(AttireSuggestionPredictionModel(model: model)))
            }
        }
    }

    /**
        Construct AttireSuggestionPredictionModel instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> AttireSuggestionPredictionModel {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return AttireSuggestionPredictionModel(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as AttireSuggestionPredictionModelInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AttireSuggestionPredictionModelOutput
    */
    func prediction(input: AttireSuggestionPredictionModelInput) throws -> AttireSuggestionPredictionModelOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as AttireSuggestionPredictionModelInput
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AttireSuggestionPredictionModelOutput
    */
    func prediction(input: AttireSuggestionPredictionModelInput, options: MLPredictionOptions) throws -> AttireSuggestionPredictionModelOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return AttireSuggestionPredictionModelOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - temperature as double value
            - humidity as double value
            - dewPoint as double value
            - windSpeed as double value
            - windGustSpeed as double value
            - windDirection as double value
            - airPressure as double value
            - totalPrecipitation as double value

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as AttireSuggestionPredictionModelOutput
    */
    func prediction(temperature: Double, humidity: Double, dewPoint: Double, windSpeed: Double, windGustSpeed: Double, windDirection: Double, airPressure: Double, totalPrecipitation: Double) throws -> AttireSuggestionPredictionModelOutput {
        let input_ = AttireSuggestionPredictionModelInput(temperature: temperature, humidity: humidity, dewPoint: dewPoint, windSpeed: windSpeed, windGustSpeed: windGustSpeed, windDirection: windDirection, airPressure: airPressure, totalPrecipitation: totalPrecipitation)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [AttireSuggestionPredictionModelInput]
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [AttireSuggestionPredictionModelOutput]
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    func predictions(inputs: [AttireSuggestionPredictionModelInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [AttireSuggestionPredictionModelOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [AttireSuggestionPredictionModelOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  AttireSuggestionPredictionModelOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
