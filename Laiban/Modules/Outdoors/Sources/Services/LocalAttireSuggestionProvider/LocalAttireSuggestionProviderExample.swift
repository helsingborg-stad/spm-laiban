//import SwiftUI
//import Weather
//import Combine
//
//@MainActor class AttireSuggestionService : ObservableObject {
//    enum Status:String {
//        case booting
//        case training
//        case ready
//        case failed
//    }
//    let garmentProvider:LBAttireSuggestionGarmentProvider
//    let dataProvider:SMHIAttireSuggestionDataProvider
//    let attireProvider:LocalAttireSuggestionProvider
//    let weather = Weather(service: SMHIForecastService())
//    let latitude:Double = 59.323840
//    let longitude:Double = 13.466290
//    var cancellables = Set<AnyCancellable>()
//    @Published var status:Status = .booting
//    @Published var weatherData:WeatherData?
//    @Published var garments:[Garment] = []
//    init() {
//        let gp = LBAttireSuggestionGarmentProvider()
//        garmentProvider = gp
//        // Use period "corrected-archive" to train a complete model (it takes a few minutes)
//        dataProvider = SMHIAttireSuggestionDataProvider(latitude: latitude, longitude: longitude, period: "latest-months", garmentProvider: gp)
//        attireProvider = LocalAttireSuggestionProvider(garmentProvider: gp)
//        weather.coordinates = .init(latitude: latitude, longitude: longitude)
//
//        Task {
//            do {
//                status = .training
//                if await attireProvider.requiresTraining {
//                    try await attireProvider.resetTrainingDataUsing(provider: dataProvider)
//                    try await attireProvider.train()
//                }
//                status = .ready
//                predictAttire()
//            } catch {
//                status = .failed
//                print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
//            }
//        }
//        weather.closest().sink { data in
//            self.weatherData = data
//            self.predictAttire()
//        }.store(in: &cancellables)
//    }
//    func predictAttire() {
//        Task {
//            guard let data = weatherData else {
//                return
//            }
//            if await attireProvider.requiresTraining {
//                return
//            }
//            guard let result = try await attireProvider.predict(
//                temperature: data.airTemperature,
//                humidity: Double(data.relativeHumidity),
//                dewPoint: Weather.dewPointAdjustedTemperature(humidity: Double(data.relativeHumidity), temperature: data.airTemperature),
//                windSpeed: data.windSpeed,
//                windGustSpeed: data.windGustSpeed,
//                windDirection: data.windDirection,
//                airPressure: data.airPressure,
//                totalPrecipitation: data.maxPrecipitation
//            ).first else {
//                print("⛔️ [\(#fileID):\(#function):\(#line)] " + "no result?")
//                return
//            }
//            self.garments = Garment.garments(from: result.attire)
//        }
//    }
//}
//
//struct AttireSuggestionView: View {
//    @ObservedObject var attireSuggestionService:AttireSuggestionService
//    var body: some View {
//        VStack {
//            Text("Status: \(attireSuggestionService.status.rawValue)")
//            if attireSuggestionService.weatherData != nil {
//                Text("Temperature: \(attireSuggestionService.weatherData!.airTemperatureFeelsLike)°")
//            }
//            ForEach(attireSuggestionService.garments) { garment in
//                Text(garment.rawValue)
//            }
//        }
//        .padding()
//    }
//}
