//
//  foreCastTableCell.swift
//  weather-app
//
//  Created by abraams141 on 7/31/21.
//  Copyright © 2021 mohammad 141. All rights reserved.
//

import UIKit

class foreCastTableCell: UITableViewCell {
    static let ID: String = "forecastCell"
    @IBOutlet var weatherImage: UIImageView!
    
    @IBOutlet var timeLbl: UILabel!
    
    @IBOutlet var conditionLbl: UILabel!
    
    @IBOutlet var degreeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
