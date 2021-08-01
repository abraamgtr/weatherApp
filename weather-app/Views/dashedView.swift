//
//  dashedView.swift
//  weather-app
//
//  Created by abraams141 on 7/31/21.
//  Copyright © 2021 mohammad 141. All rights reserved.
//

import UIKit

class dashedView: UIView {
    
    @IBInspectable var backColor: UIColor = UIColor.systemBlue {

            didSet{
                self.layer.backgroundColor = self.backColor.cgColor
            }

        }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.*/
    override func draw(_ rect: CGRect) {
        let  path = UIBezierPath()

        let  p0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
        path.move(to: p0)

        let  p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
        path.addLine(to: p1)

        let  dashes: [ CGFloat ] = [ 2, 4 ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)

        path.lineWidth = 2
        path.lineCapStyle = .butt
        UIColor(cgColor: self.backColor.cgColor).set()
        path.stroke()
    }

}
