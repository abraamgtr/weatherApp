//
//  ViewController.swift
//  weather-app
//
//  Created by mohammad 141 on 8/30/20.
//  Copyright © 2020 mohammad 141. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import Network

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var weatherImage: UIImageView!
    
    @IBOutlet var placeLbl: UILabel!
    
    @IBOutlet var conditionLbl: UILabel!
    
    @IBOutlet var rainyLbl: UILabel!
    
    @IBOutlet var humidityLbl: UILabel!
    
    @IBOutlet var pressureLbl: UILabel!
    
    @IBOutlet var windLbl: UILabel!
    
    @IBOutlet var poleLbl: UILabel!
    
    @IBOutlet var loadSpinner: UIActivityIndicatorView!
    
    @IBOutlet var dataView: UIView!
    
    @IBOutlet var shareBtn: UIButton!
    
    @IBOutlet var shareDashView: dashedView!
    
    //variables
    var locationManager: CLLocationManager!
    // internet connection alert
    var internetAlertController = UIAlertController()
    
    
    
    //variables
    private let dataSource = DataModel()
    let connectionHandler = NetworkHandler()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.loadSpinner.startAnimating()
        self.dataView.isHidden = true
        self.shareBtn.isHidden = true
        self.shareDashView.isHidden = true
        dataSource.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        setup()
    }
    
    @objc func internetHandler(_ notification: Notification) {
        print("internet notification")
        if (!showConnectionAlert) {
            internetAlertController = UIAlertController(title: "Internet Connection", message: "Please authorize check your internet connection", preferredStyle: .alert)
            internetAlertController.show()
            showConnectionAlert = true
        }
        
    }
    
    @objc func loadWeatherNotification(_ notification: Notification) {
       
        dataSource.requestData()
    }
    
    @objc func loadWeather() {
       
        dataSource.requestData()
    }
    
    private func setup() {
        connectionHandler.startConnectionMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(internetHandler(_:)), name: .internetConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadWeatherNotification(_:)), name: .locationChanged, object: nil)
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadWeather()
        LocationManagerCustom.shared.requestLocationAuthorization()
        LocationManagerCustom.shared.getUserLocation(queue: DispatchQueue.main) { userLocation in
            print(userLocation!.coordinate)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingHeading()
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        let activityVC = UIActivityViewController( activityItems: ["\(self.conditionLbl.text ?? ""), \(self.placeLbl.text ?? "") by WeatherApp"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func presentLocationAlert() {
        let alert = UIAlertController(title: "Location Permission", message: "Please authorize application to get weather data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                    // Create a CLLocationManager and assign a delegate
                    let locationManager = CLLocationManager()
                    locationManager.delegate = self
                    locationManager.requestAlwaysAuthorization()
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    

}
extension ViewController : DataModelDelegate{
    func didRecieveData(data: weather) {
        print("data receieved")
        //showConnectionAlert = false
        internetAlertController.dismiss(animated: true, completion: nil)
        self.loadSpinner.stopAnimating()
        self.dataView.isHidden = false
        self.shareBtn.isHidden = false
        self.shareDashView.isHidden = false
        self.weatherImage.image = data.getWeatherImage()
        self.placeLbl.text = data.getWeatherPlace()
        self.conditionLbl.text = "\(data.getWeatherTemp())℃ | \(data.getWeatherMainDesc())"
        self.humidityLbl.text = String(data.getWeatherHumidity())
        self.pressureLbl.text = String(data.getWeatherPressure()) + "hPa"
        self.windLbl.text = String(data.getWindSpeed()) + "km/h"
    }

    func didFailWithError(error: Error) {
        print("error:  \(error.localizedDescription)")
        if (error.localizedDescription.contains("appears to be offline")) {
            //showConnectionAlert = false
            NotificationCenter.default.post(name: .internetConnection, object: nil, userInfo: nil)
        }
    }
    func getNameWithCompletion(completion: (String) -> ()) {
        completion("mohammad")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationPermissionGrant: Bool = dataSource.getLocationPermissionStatus()
        
        if (!locationPermissionGrant) {
            //presentLocationAlert()
        }
//        if status == .authorizedAlways {
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//                if CLLocationManager.isRangingAvailable() {
//                    // do stuff
//                }
//            }
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location changed")
        NotificationCenter.default.post(name: .locationChanged, object: nil, userInfo: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
            print("heading = \(newHeading.magneticHeading)")
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("heading = \(newHeading.magneticHeading)")
        let heading = newHeading.magneticHeading.rounded()
        switch heading {
        case 0:
            self.poleLbl.text = "N"
        case 90:
            self.poleLbl.text = "E"
        case 180:
            self.poleLbl.text = "S"
        case 270:
            self.poleLbl.text = "W"
        default:
            self.poleLbl.text = "N"
        }
        if (heading > 0 && heading < 90) {
            self.poleLbl.text = "NE"
        } else if (heading > 90 && heading < 180) {
            self.poleLbl.text = "ES"
        } else if (heading > 180 && heading < 270) {
            self.poleLbl.text = "SW"
        } else if (heading > 270 && heading < 360) {
            self.poleLbl.text = "WN"
        }
    }

}

class LocationManagerCustom: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManagerCustom()
    private var locationManager: CLLocationManager = CLLocationManager()
    private var requestLocationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?
    private let privateQueue = DispatchQueue.init(label: "somePrivateQueue")
        private var latestLocation: CLLocation!{
            didSet{
                privateQueue.resume()
            }
        }

        func getUserLocation(queue: DispatchQueue, callback: @escaping (CLLocation?) -> Void) {
            if latestLocation == nil{
                privateQueue.suspend() //pause queue. wait until got a location
            }

            privateQueue.async{ //enqueue work. should run when latestLocation != nil

                queue.async{ //use a defined queue. most likely mainQueue

                  callback(self.latestLocation)
                  //optionally clear self.latestLocation to ensure next call to this method will wait for new user location. But if you are okay with a cached userLocation, then no need to clear.
                }
            }

        }

    public func requestLocationAuthorization() {
        self.locationManager.delegate = self
        let currentStatus = CLLocationManager.authorizationStatus()

        // Only ask authorization if it was never asked before
        guard currentStatus == .denied else { return }

        // Starting on iOS 13.4.0, to get .authorizedAlways permission, you need to
        // first ask for WhenInUse permission, then ask for Always permission to
        // get to a second system alert
        if #available(iOS 13.4, *) {
            self.requestLocationAuthorizationCallback = { status in
                if status == .authorizedWhenInUse {
                    self.locationManager.requestAlwaysAuthorization()
                }
            }
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestLocationAuthorizationCallback?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location changed")
        NotificationCenter.default.post(name: .locationChanged, object: nil, userInfo: nil)
    }
}
