//
//  Network.swift
//  weather-app
//
//  Created by abraams141 on 8/1/21.
//  Copyright © 2021 mohammad 141. All rights reserved.
//

import Foundation
import Network
import UIKit

var showConnectionAlert = false

class NetworkHandler {
    // create instance of network connection
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    
    func startConnectionMonitoring() {
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                print("Internet connection is on.")
                
            } else {
                print("There's no internet connection.")
//                NotificationCenter.default.post(name: .internetConnection, object: nil, userInfo: nil)
            }
        }

        monitor.start(queue: queue)
    }
    
    
}
extension ViewController {
    func presentInternetAlert() {
        let alert = UIAlertController(title: "Internet Connection", message: "Please authorize check your internet connection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                    // Create a CLLocationManager and assign a delegate
                    
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
extension ForecastVC {
    func presentInternetAlert() {
        let alert = UIAlertController(title: "Internet Connection", message: "Please authorize check your internet connection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                    // Create a CLLocationManager and assign a delegate
                    
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if
            let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController
        {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else if
            let tabVC = controller as? UITabBarController,
            let selectedVC = tabVC.selectedViewController
        {
            presentFromController(controller: selectedVC, animated: animated, completion: completion)
        } else if let presented = controller.presentedViewController {
            presentFromController(controller: presented, animated: animated, completion: completion)
        } else {
            controller.present(self, animated: animated, completion: completion);
        }
    }
}
