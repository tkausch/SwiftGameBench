//
//  ConnectBoardView.swift
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

protocol ConnectBoardViewDelegate {
    func didSelectColumn(_ column: Int);
}


class ConnectBoardView: UIView {
    
    var boardCells = [ConnectBoardViewCell]()
    var delegate: ConnectBoardViewDelegate?
    
    static let NumberOfRows = 6
    static let NumberOfColumns = 7
    
    // do not update
    var disableUpdates = false
    
    // board margin
    var margin  = CGFloat(3)
    
    // used for board rounded corners
    var boardCornerRadius = 3
    
    // board background color
    var boardColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
    
    // cell color for black player
    var blackPlayerCellColor = UIColor.black
    
    // cell color for white player
    var whitePlayerCellColor = UIColor.red
    
    // cell color for empty cell
    var emptyCellColor = UIColor.white
    
    var board: ConnectBoard? {
        didSet  {
            NotificationCenter.default.addObserver(self, selector: #selector(ConnectBoardView.cellDidChange(_:)), name: NSNotification.Name(rawValue: ConnectBoard.CellDidChangeNotification) , object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(ConnectBoardView.endOfGame(_:)), name: NSNotification.Name(rawValue: ConnectBoard.EndOfGameNotification), object: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.backgroundColor = boardColor
        layer.cornerRadius = CGFloat(boardCornerRadius)
        layer.masksToBounds = true
        
        layer.borderColor = UIColor.gray.cgColor;
        layer.borderWidth = CGFloat(0.2);
        
        addBoardCells()
        
    }
    
    
    func reset() {
        for cell in boardCells {
            cell.cellColor = UIColor.clear
            cell.highlighted = false
            cell.setNeedsDisplay()
        }
    }
    
    
    func addBoardCells() {
        for row  in 0 ..< ConnectBoardView.NumberOfRows   {
            for column in 0 ..< ConnectBoardView.NumberOfColumns  {
                let cell = ConnectBoardViewCell(indexPath: NSIndexPath.init(row: row, section: column))
                cell.delegate = self
                self.addSubview(cell)
                boardCells.append(cell)
            }
        }
    }
    
    
    override func layoutSubviews() {
        
        
        let cellHeight = (CGFloat(bounds.size.height) - 2 * margin) / CGFloat(ConnectBoardView.NumberOfRows)
        let cellWidth = (CGFloat(bounds.size.width) - 2 * margin) / CGFloat(ConnectBoardView.NumberOfColumns)
        
        let originY = CGFloat(ConnectBoardView.NumberOfRows-1) * cellHeight
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for cell in boardCells {
            let row = cell.indexPath.row
            let column  = cell.indexPath.section
            cell.frame = CGRect(x: CGFloat(column) *  cellWidth + margin,  y: originY - CGFloat(row) * cellHeight + margin, width: cellWidth, height: cellHeight)
            cell.setNeedsLayout()
            cell.setNeedsDisplay()
        }
        
        CATransaction.commit()
        
    }
    
    func didSelectColumn(_ column: Int) {
        if let connectBoardViewDelegate = delegate {
            connectBoardViewDelegate.didSelectColumn(column)
        }
    }
    
    
    func cellColor(row: Int, column: Int) -> UIColor {
        if let connectBoard = board {
            switch (connectBoard[row + 1,column + 1]) {
            case .black:
                return blackPlayerCellColor
            case .white:
                return whitePlayerCellColor
            case .none:
                return emptyCellColor
                
            }
        }
        return UIColor.white
    }
    
    @objc func cellDidChange(_ notification: Notification) {
        if let userInfoDictionary = notification.userInfo as? Dictionary<String,NSNumber> {
            if let column  = userInfoDictionary["column"] {
                if let row = userInfoDictionary["row"] {
                    self.updateCell(Int(truncating: row) - 1, column: Int(truncating: column) - 1)
                }
            }
        }
    }
    
    @objc func endOfGame(_ notification: Notification) {
        if let userInfoDictionary = notification.userInfo as? Dictionary<String,NSNumber> {
            if let column = userInfoDictionary["column"] {
                if let row = userInfoDictionary["row"] {
                    if let direction = userInfoDictionary["direction"] {
                        updateFourCellsInRow(Int(truncating: row) - 1, column: Int(truncating: column) - 1, direction: Int(truncating: direction))
                    }
                }
            }
        }
    }
    
    func updateFourCellsInRow(_ row:Int, column:Int, direction:Int) {
        if disableUpdates {
            return
        }
        var cellIndex = row * ConnectBoardView.NumberOfColumns + column;
        for _ in  0...3 {
            let cell = boardCells[cellIndex]
            cell.highlighted = true
            cell.setNeedsDisplay()
            cellIndex += direction
        }
    }
    
    func updateCell(_ row: Int, column: Int) {
        if disableUpdates {
            return
        }
        let cellIndex = row * ConnectBoardView.NumberOfColumns + column
        DispatchQueue.main.async {
            self.boardCells[cellIndex].setNeedsDisplay()
        }
    }
    
}

extension ConnectBoardView: ConnectBoardViewCellDelegate, ConnectBoardViewCellDataSource {
    
    func connectBoardCellView(cell: ConnectBoardViewCell, didSelectRowAtIndexPath index: NSIndexPath) {
        self.didSelectColumn(index.section)
    }
    
    func connectBoardCellView(cell: ConnectBoardViewCell, colorForRowAtIndexPath index: NSIndexPath) -> UIColor {
        return self.cellColor(row: index.row, column: index.section)
    }
}


