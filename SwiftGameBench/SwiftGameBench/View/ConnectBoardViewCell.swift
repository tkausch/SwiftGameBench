//
//  ConnectBoardCell.swift
//  SwiftGameBench
//
//  Created by Thomas Kausch on 01/08/17.
//  Copyright (c) 2017 Thomas Kausch. All rights reserved.
//
//
//  SwiftGameBench is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General   License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  SwiftGameBench is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General   License for more details.
//
//  You should have received a copy of the GNU General   License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

protocol ConnectBoardViewCellDelegate {
    func connectBoardCellView(cell: ConnectBoardViewCell, didSelectRowAtIndexPath: NSIndexPath)
}

protocol ConnectBoardViewCellDataSource {
    func connectBoardCellView(cell: ConnectBoardViewCell, colorForRowAtIndexPath: NSIndexPath) -> UIColor
}

class ConnectBoardViewCell: UIView {
    
    var delegate: (ConnectBoardViewCellDelegate & ConnectBoardViewCellDataSource)?
    var cellColor = UIColor.clear
    var highlighted: Bool = false
    let indexPath: NSIndexPath
    
    init(indexPath: NSIndexPath) {
        self.indexPath = indexPath
        super.init(frame:CGRect.zero)
        backgroundColor = UIColor.clear
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(ConnectBoardViewCell.tappedCell(_:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        assert(false, "ConnectBoardCellView should not be loaded from NIB!")
        return nil
    }
    
    override func draw(_ rect: CGRect) {
        
       let ctx = UIGraphicsGetCurrentContext()
        
        // clip circle
        let circleRect = self.bounds.insetBy(dx: 3  , dy: 3)
        let circleRadius = circleRect.height * 0.5
        let circlePath = UIBezierPath(roundedRect: circleRect, cornerRadius: circleRadius)
        
        // fille circle with player color
        
        if let nextCellColor = delegate?.connectBoardCellView(cell: self, colorForRowAtIndexPath: self.indexPath) {
            
            ctx?.setFillColor(nextCellColor.cgColor)
            ctx?.addPath(circlePath.cgPath)
            ctx?.fillPath()
            
            // outline circle
            var circleColor = UIColor.black.cgColor
            var circleLineWidth: CGFloat  = 0.1
            
            if highlighted {
                circleColor = UIColor.yellow.cgColor
                circleLineWidth  = 3.0
            }
            
            ctx?.setStrokeColor(circleColor)
            ctx?.setLineWidth(circleLineWidth)
            ctx?.addPath(circlePath.cgPath)
            ctx?.strokePath()
            
            // if color has changed flip coin - to make change visible
            if (!cellColor.isEqual(nextCellColor)) {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
                }) { (finished) -> Void in
                    self.cellColor = nextCellColor
                }
                
            }
        }
    }
    
    @objc func tappedCell(_ recognizer:UITapGestureRecognizer) {
        self.delegate?.connectBoardCellView(cell: self, didSelectRowAtIndexPath:self.indexPath)
    }
    
    
}
