//
//  ForecastVC.swift
//  weather-app
//
//  Created by abraams141 on 7/31/21.
//  Copyright © 2021 mohammad 141. All rights reserved.
//

import UIKit
import SDWebImage

class ForecastVC: UIViewController {
    @IBOutlet var forecastTableView: UITableView!
    
    @IBOutlet var loadSpinner: UIActivityIndicatorView!
    
    //variables
    private let dataSource = DataModel()
    var forecastList = [Dictionary<Date, [forecastWeather]>.Element]()
    let commons = Commons()
    let connectionHandler = NetworkHandler()
    // internet connection alert
    var internetAlertController = UIAlertController()
    
    @objc func internetHandler(_ notification: Notification) {
        if (!showConnectionAlert) {
            internetAlertController = UIAlertController(title: "Internet Connection", message: "Please authorize check your internet connection", preferredStyle: .alert)
            internetAlertController.show()
            showConnectionAlert = true
        }
    }
    
    func loadWeather() {
       
        dataSource.request5daysData()
        self.loadSpinner.startAnimating()
        self.forecastTableView.isHidden = true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        self.forecastTableView.sectionHeaderHeight = 70
        NotificationCenter.default.addObserver(self, selector: #selector(internetHandler(_:)), name: .internetConnection, object: nil)
        dataSource.forecastDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadWeather()
    }

}
extension ForecastVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.forecastList.count > 0) {
            switch section {
            case 0:
                return self.forecastList[0].value.count
            case 1:
                return self.forecastList[1].value.count
            case 2:
                return self.forecastList[2].value.count
            case 3:
                return self.forecastList[3].value.count
            case 4:
                return self.forecastList[4].value.count
            default:
                return 0
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.forecastList.count > 0) {
            switch section {
            case 0:
                return "Today"
            case 1:
                return commons.getDayName(self.forecastList[1].key)
            case 2:
                return commons.getDayName(self.forecastList[2].key)
            case 3:
                return commons.getDayName(self.forecastList[3].key)
            case 4:
                return commons.getDayName(self.forecastList[4].key)
            default:
                return "Other"
            }
        }
        return ""
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        self.forecastTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.forecastTableView.bounds.size.width, height: 70))
        self.forecastTableView.contentInset = UIEdgeInsets(top: -70, left: 0, bottom: 0, right: 0)
        let topDivider = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 1))
        if #available(iOS 13.0, *) {
            topDivider.backgroundColor = UIColor.label.withAlphaComponent(0.54)
        } else {
            topDivider.backgroundColor = UIColor.black.withAlphaComponent(0.54)
        }
        
        let bottomDivider = UIView.init(frame: CGRect.init(x: 0, y: 69, width: tableView.frame.width, height: 1))
        if #available(iOS 13.0, *) {
            bottomDivider.backgroundColor = UIColor.label.withAlphaComponent(0.54)
        } else {
            bottomDivider.backgroundColor = UIColor.black.withAlphaComponent(0.54)
        }
        if (section != 0) {
            headerView.addSubview(topDivider)
        }
        
        headerView.addSubview(bottomDivider)
                
                let label = UILabel()
                label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
                label.text = ""
                if (self.forecastList.count > 0) {
                    switch section {
                    case 0:
                        label.text = "Today"
                    case 1:
                        label.text =  commons.getDayName(self.forecastList[1].key)
                    case 2:
                        label.text =  commons.getDayName(self.forecastList[2].key)
                    case 3:
                        label.text =  commons.getDayName(self.forecastList[3].key)
                    case 4:
                        label.text =  commons.getDayName(self.forecastList[4].key)
                    default:
                        label.text =  "Other"
                    }
                }
                label.font = .systemFont(ofSize: 20, weight: .medium)
                if #available(iOS 13.0, *) {
                    label.textColor = UIColor.label.withAlphaComponent(1.0)
                } else {
                    label.textColor = UIColor.black.withAlphaComponent(1.0)
                }
                
                headerView.addSubview(label)
                
                return headerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.forecastTableView.dequeueReusableCell(withIdentifier: foreCastTableCell.ID) as! foreCastTableCell
        if (self.forecastList.count > 0) {
//            cell.timeLbl.text = "\(self.forecastList[indexPath.section].value[indexPath.row].getWeatherTime())".split{$0 == " "}.map(String.init)[1]
            cell.weatherImage.sd_setImage(with: URL(string: self.forecastList[indexPath.section].value[indexPath.row].getWeatherImage()), placeholderImage: UIImage(named: "placeholder.png"))
            cell.timeLbl.text = commons.getTimeInFormat(self.forecastList[indexPath.section].value[indexPath.row].getWeatherTime())
            cell.conditionLbl.text = self.forecastList[indexPath.section].value[indexPath.row].getWeatherMainDesc()
            cell.degreeLbl.text = String(self.forecastList[indexPath.section].value[indexPath.row].getWeatherTemp()) + "°"
        }
        return cell
    }
}
extension ForecastVC : ForecastDataModelDelegate{
    func didRecieveData(data: [Dictionary<Date, [forecastWeather]>.Element]) {
        print(data)
        //showConnectionAlert = false
        internetAlertController.dismiss(animated: true, completion: nil)
        self.loadSpinner.stopAnimating()
        self.forecastTableView.isHidden = false
        self.forecastList = data
        self.forecastTableView.reloadData()
    }

    func didFailWithError(error: Error) {
        print("error:  \(error.localizedDescription)")
        if (error.localizedDescription.contains("appears to be offline")) {
            showConnectionAlert = false
            NotificationCenter.default.post(name: .internetConnection, object: nil, userInfo: nil)
        }
    }

}
