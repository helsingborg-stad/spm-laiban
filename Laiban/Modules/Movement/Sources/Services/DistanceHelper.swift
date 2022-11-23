//
//  DistanceHelper.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-18.
//

import Foundation
import CoreLocation
import Analytics

public class DistanceHelper: NSObject, CLLocationManagerDelegate {

    private let baseUrl = "http://api.geonames.org/findNearbyPlaceNameJSON?lat=%@&lng=%@&username=%@&radius=%@&style=short&maxRows=500%@"
    var locationManager: CLLocationManager
    private var location: CLLocation?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        handleAuthorization()
    }
    
    private func handleAuthorization() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if [.authorizedWhenInUse, .authorizedAlways].contains(authorizationStatus) {
            locationManager.requestLocation()
        }
    }

    public func getCities(withRange: Double, actualDistance: Double, completion: @escaping ([City]?) -> Void) {
        if let urlString = prepareUrl(range: withRange), let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url){
                    data, response, error in
                    
                    if let data = data, let string = String(data: data, encoding: .utf8){
                        print(string)
                        if let cities = try? JSONDecoder().decode(MovementCityModel.self, from: data){
                            if var startCity = self.findCityClosestTo(distance: 0, from: cities), var desinationCity = self.findCityClosestTo(distance: actualDistance, from: cities) {
                                startCity.start = true
                                desinationCity.destination = true
                                
                                completion([startCity, desinationCity])
                                return
                            }
                        }
                    }
                    completion(nil)
                }

                task.resume()
        }
    }
    
    private func findCityClosestTo(distance: Double, from model: MovementCityModel) -> City? {
        let closestMatch = model.cities.filter({$0.countryCode == "SE"}).enumerated().min( by: { abs((Double($0.1.distance) ?? 0) - distance) < abs((Double($1.1.distance) ?? 0) - distance) })
        return closestMatch?.element
    }
    
    private func prepareUrl(range: Double) -> String? {
        let parameterRange = String(max(2, min(range, 300))) // Make sure range is between 2-300 km
        var cityType: CityTypes = .none
        if (20...100).contains(range) {
            cityType = .cities1000
        } else if (100...200).contains(range) {
            cityType = .cities5000
        } else if range > 200 {
            cityType = .cities15000
        }
        
        if let coordinates =  location?.coordinate {
            return String.init(format: baseUrl, String(coordinates.latitude.description), String(coordinates.longitude.description), "laibanpm", parameterRange, cityType.rawValue)
        }
        return nil
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AnalyticsService.shared.logError(error)
    }
    
    enum CityTypes: String, Codable {
        case cities1000 = "&cities=cities1000"
        case cities5000 = "&cities=cities5000"
        case cities15000 = "&cities=cities15000"
        case none = ""
    }
}
