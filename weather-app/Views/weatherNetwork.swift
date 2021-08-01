//
//  weatherNetwork.swift
//  weather-app
//
//  Created by mohammad 141 on 8/30/20.
//  Copyright © 2020 mohammad 141. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import SwiftLocation
import CoreLocation
import AlamofireImage

protocol DataModelDelegate:AnyObject {
    func didRecieveData(data:weather)
    func didFailWithError(error:Error)
}

protocol ForecastDataModelDelegate:AnyObject {
    func didRecieveData(data:[Dictionary<Date, [forecastWeather]>.Element])
    func didFailWithError(error:Error)
}

class DataModel {
    weak var delegate : DataModelDelegate?
    weak var forecastDelegate : ForecastDataModelDelegate?
    
    func getLocationPermissionStatus() -> Bool {
        // Get the current location permissions
        let status = CLLocationManager.authorizationStatus()

        // Handle each case of location permissions
        switch status {
            case .authorizedAlways:
                return true
            case .authorizedWhenInUse:
                return true
            case .denied:
                return false
            case .notDetermined:
                return false
            case .restricted:
                return false
        @unknown default:
            return false
        }
    }
    
    func getLocationPermission(completion: @escaping (Bool) -> ()) {
        // getting always usage location permission
        CLLocationManager().requestAlwaysAuthorization()
        completion(true)
    }
    
    func requestData()  {
        var weatherDesc: weatherImage!
        self.getGpsCoord { (location) in
            //print("location = \(location)")
            let url: String = AppDelegate.weatherUrl + "lat=\(location.latitude)&lon=\(location.longitude)&units=metric&appid=\(AppDelegate.APIKEY)"
            
            AF.request(URL(string: url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in

                switch response.result {

                case .success(_):
                    //showConnectionAlert = false
                    if let json = try? JSON(data: response.data!) {
                        //print(json)
                        self.getWeatherImage(imageUrl: AppDelegate.weatherImageUrl + "\(json["weather"][0]["icon"].stringValue)@2x.png") { (image) in
                            switch json["weather"][0]["description"].stringValue.replacingOccurrences(of: " ", with: "") {
                            case "clearsky":
                                weatherDesc = .clearsky
                                break
                            case "fewclouds":
                                weatherDesc = .fewclouds
                                break
                            case "scatteredclouds":
                                weatherDesc = .scatteredclouds
                                break
                            case "brokenclouds":
                                weatherDesc = .brokenclouds
                                break
                            case "showerrain":
                                weatherDesc = .showerrain
                                break
                            case "rain":
                                weatherDesc = .rain
                                break
                            case "thunderstorm":
                                weatherDesc = .thunderstorm
                                break
                            case "snow":
                                weatherDesc = .snow
                                break
                            case "mist":
                                weatherDesc = .mist
                                break
                            default:
                                weatherDesc = .clearsky
                                break
                            }
                            let weatherData = weather(
                                
                                place: "\(json["sys"]["country"].stringValue), \(json["name"].stringValue)",
                                lat: json["coord"]["lat"].stringValue, long: json["coord"]["lon"].stringValue, main: json["weather"][0]["main"].stringValue, temp: Float(json["main"]["temp"].stringValue)!,humidity: json["main"]["humidity"].floatValue,pressure: json["main"]["pressure"].floatValue,windSpeed: json["wind"]["speed"].floatValue, image: image, weatherDescription: weatherDesc)
                            
                            self.delegate?.didRecieveData(data: weatherData)
                        }
                    }
                    break
                case .failure(let error):
                    self.delegate?.didFailWithError(error: error)
                    break
                }
            }
        }
        

    }
    
    func request5daysData()  {
        var weatherDesc: weatherImage!
        var getUserLocationTimer = Timer.scheduledTimer(timeInterval: 10800.0, target: self, selector: #selector(self.getDelayedGpsCoord), userInfo: nil, repeats: true)
        
        getUserLocationTimer.fire()

    }
    
    func getGpsCoord(completion: @escaping (CLLocationCoordinate2D) -> ()) {
        _ = LocationManager.shared.locateFromGPS(.continous, accuracy: .city) { result in
          switch result {
            case .failure(let error):
              debugPrint("Received error: \(error)")
                self.getLocationPermission { done in
                    
                }
            case .success(let location):
                completion(location.coordinate)
          }
        }

    }
    
    // get location and update forecast every 3 hours
    @objc func getDelayedGpsCoord() {
        _ = LocationManager.shared.locateFromGPS(.oneShot, accuracy: .city) { result in
          switch result {
            case .failure(let error):
              debugPrint("Received error: \(error)")
                self.getLocationPermission { done in
                    
                }
            case .success(let location):
                //print("location = \(location)")
                let url: String = AppDelegate.forecast5daysWeatherUrl + "lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(AppDelegate.APIKEY)"
                
                //print(url)
                
                AF.request(URL(string: url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in

                    switch response.result {

                    case .success(_):
                        if let json = try? JSON(data: response.data!) {
                            //print(json)
                            var forecastWeatherList: [forecastWeather] = []
                            // build our forecast weather list
                            let group = DispatchGroup()
                            //var count = 0
                            for weatherItem in json["list"] {
                                group.enter()
                                //print("count = \(count)")
                                forecastWeatherList.append(forecastWeather(time: weatherItem.1["dt_txt"].stringValue, main: weatherItem.1["weather"][0]["main"].stringValue, temp: weatherItem.1["main"]["temp"].floatValue, image:AppDelegate.weatherImageUrl + "\(weatherItem.1["weather"][0]["icon"].stringValue)@2x.png", weatherDescription: weatherItem.1["weather"][0]["description"].stringValue))
                                //count += 1
                                if (forecastWeatherList.count == json["cnt"].intValue) {
                                    
                                    group.leave()
                                    let empty: [Date: [forecastWeather]] = [:]
                                    let groupedByDate = forecastWeatherList.reduce(into: empty) { acc, cur in
                                        //print("acc \(acc) cur = \(cur)")
                                        let components = Calendar.current.dateComponents([.year, .month, .day], from: cur.getWeatherTime())
                                        let date = Calendar.current.date(from: components)!
                                        let existing = acc[date] ?? []
                                        acc[date] = existing + [cur]
                                    }
                                    let sortedKeysAndValues = groupedByDate.sorted {
                                        return $0.0 < $1.0
                                    }
                                    //print("grouped forecast = \(sortedKeysAndValues[0])")
                                    self.forecastDelegate?.didRecieveData(data: sortedKeysAndValues)
                                }
                                
                            }
                        }
                        break
                    case .failure(let error):
                        self.delegate?.didFailWithError(error: error)
                        break
                    }
                }
          }
        }

    }
    
    func getWeatherImage(imageUrl:String, completion: @escaping (UIImage) -> ()) {
        AF.request(imageUrl).responseImage { response in

            if case .success(let image) = response.result {
                completion(image)
            }
        }
    }
}
