//
//  Commons.swift
//  weather-app
//
//  Created by abraams141 on 8/1/21.
//  Copyright © 2021 mohammad 141. All rights reserved.
//

import Foundation

class Commons {
    func getDayName(_ dateInput: Date) -> String {
        // get day full name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfTheWeekString = dateFormatter.string(from: dateInput)
        
        return dayOfTheWeekString
    }
    // get time in fromat of 19:30
    func getTimeInFormat(_ dateInput: Date) -> String {
        // get time in fromat of 19:30
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let formattedTime = dateFormatter.string(from: dateInput)
        
        print("formatted date = \(formattedTime)")
        
        return formattedTime
    }
}
