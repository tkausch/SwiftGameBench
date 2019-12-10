//
//  ConnectBoard.swift
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

import Foundation
import SwiftGameBenchFramework

/*

     ConnectBoard class is using the following matrix to represent a connect board:

       - | - - - - - - - | -
       –––––––––––––––––––––
       - | - - - - - - - | -
       - | - - - - - - - | -
       - | - - - - - - - | -
       - | - - - - - - - | -
       - | - 0 - - - - - | -
       - | x 0 x - - - - | -
       –––––––––––––––––––––
       - | - - - - - - - | -

      where x = Player.white, 0 = Player.black and - = Player.None.

      Note: There is an extra row and column with constant values Player.None.
      This makes it easier to determine if game ist over. We don't have to check
      for crossing the matrix borders. 

      This matrix is mapped to a one dimensional array named cells
 
*/

class ConnectBoard: Board, CustomStringConvertible, Equatable  {
    
    

    static let CellDidChangeNotification = "ConnectBoardIsEndOfGameNotification"
    static let EndOfGameNotification = "ConnectBoardEndOfGameNotification"
    
    static let NumberOfColumnes  = 7
    static let NumberOfRows = 6
  
    var nextPlayer = Player.white
    var isEndPosition = false
    var winner = Player.none
    var isSearching = false

    
    fileprivate static let NumberOfCells = (7 + 2) * (6 + 2)
    fileprivate static let WeightsForColumn = [0, 10, 20, 40, 80, 40, 20, 10, 0]
    fileprivate static let Directions = [8, 9, 10, 1]     // LeftUp, Up, RightUp, Right
    
    fileprivate var shuffledColumns = [4,3,5,2,6,1,7];
    fileprivate var cells = [Player](repeating: Player.none,  count: ConnectBoard.NumberOfCells)
    fileprivate var topRowIndexForColumn = [0, 1, 1, 1, 1, 1, 1, 1, 0]
    fileprivate var moveCount = 0
    fileprivate var totalCellWeight = 0
    
    
// MARK: - Board methods
    
    
    var validMoves: [ConnectMove] {
        
        var validMoves = [ConnectMove]();
        if !isEndPosition {
            shuffle(&shuffledColumns)
            for column in shuffledColumns  {
                if !isColumnFull(column) {
                    validMoves.append(ConnectMove(player: nextPlayer, column: column))
                }
            }
        }
        return validMoves;
    }

    
    func isValidMove(_ move: ConnectMove) -> Bool {
        if !isEndPosition {
            return move.player == nextPlayer && !isColumnFull(move.column)
        } else {
            return false
        }
    }
    
    
    fileprivate func isColumnFull(_ column: Int) -> Bool {
        return topRowIndexForColumn[column] >  ConnectBoard.NumberOfRows
    }
    
    
    func doMove(_ move: ConnectMove) {
        
        // Precondition: Move is valid
        
        // set board cell to move player and adjust invariants
        let moveRow = topRowIndexForColumn[move.column]
        
        self[moveRow, move.column] = move.player
        
        moveCount += 1
        nextPlayer = self.nextPlayer.oponent()
        totalCellWeight += move.player.rawValue * ConnectBoard.WeightsForColumn[move.column]
        topRowIndexForColumn[move.column] += 1
        
        isEndPosition = checkForEndPosition(row: moveRow, column: move.column)
        
        if !isSearching {
            postCellDidChangedNotification(row: moveRow, column: move.column)
        }
        
        
    }
    

    
    func checkForEndPosition(row: Int, column: Int) -> Bool   {
        
        // Precondition: move is valid
        
        let cellIndex = row * (ConnectBoard.NumberOfColumnes + 2) + column
        let cellColor = cells[cellIndex]
        
        var counter = 0
        var foundDirection: Int?
        var foundCellIndex: Int?
        
        for direction in ConnectBoard.Directions {
            
            // find end of line of cells with the same color/player
            var index = cellIndex
            repeat {
                index += direction
            } while cells[index] == cellColor
            
            // count number of cells with same color in a line
            counter = 0
            index -= direction
            while cells[index] == cellColor {
                counter += 1
                index -= direction
            }
            
            // Check if four in a row are detected - break loop
            if counter >= 4 {
                foundDirection = direction
                foundCellIndex = index + direction
                break
            }
        }

        // Check if we have found 4 in a line or full board
        if counter >= 4 {
            self.isEndPosition = true
            winner = cellColor
            if !isSearching {
                postEndOfGameNotification(cellIndex: foundCellIndex!, direction: foundDirection!)
            }
        } else if moveCount == ConnectBoard.NumberOfRows * ConnectBoard.NumberOfColumnes {
            isEndPosition = true
            winner = Player.none
        }
        
        return isEndPosition
        
    }
    
    
    var heuristicValue: Int {
        if isEndPosition {
            switch (winner) {
            case Player.white:
                return Int.max
            case Player.black:
                return Int.min
            default:
                return 0;
            }
        } else {
            return totalCellWeight
        }
    }
    
    
    func undoMove(_ move: ConnectMove) {
            
            let lastMoveRow = topRowIndexForColumn[move.column] - 1
            
            self[lastMoveRow, move.column] = Player.none
            
            // adjust invariants
            topRowIndexForColumn[move.column] -= 1
            moveCount -= 1
            nextPlayer = nextPlayer.oponent()
            totalCellWeight -= move.player.rawValue * ConnectBoard.WeightsForColumn[move.column]
            isEndPosition = false
            
             postCellDidChangedNotification(row: lastMoveRow, column: move.column)
            
        
    }
    
    

    func moveForColumn(_ column: Int) -> ConnectMove? {
        if (!isEndPosition && column <= ConnectBoard.NumberOfColumnes && topRowIndexForColumn[column] <= ConnectBoard.NumberOfRows) {
            return ConnectMove(player: nextPlayer, column: column)
        } else {
            return nil
        }
    }
    
    
 // MARK: - Randomization
    
    
    fileprivate func shuffle(_ list: inout [Int]) {
        
        // Using Donald E. Knuth Algorithm to shuffle array in o(n) time
        for i in 0..<list.count  {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            if i != j {
                let tmp = list[i]
                list[i] = list[j]
                list[j] = tmp
            }
        }
        
    }
    

    
// MARK: - CustomStringConvertible  methods
    
    
    func reset() {
        winner = Player.none
        isEndPosition = false
        nextPlayer = Player.white
        cells = [Player](repeating: Player.none,  count: ConnectBoard.NumberOfCells)
        topRowIndexForColumn = [0, 1, 1, 1, 1, 1, 1, 1, 0]
        totalCellWeight = 0
        moveCount = 0
        isSearching = false
    }
    
    
    
    
    var description: String {
        var rtn = ""
        for row in ((0 + 1)...ConnectBoard.NumberOfRows).reversed()  {
            for col in 1...ConnectBoard.NumberOfColumnes {
                let cellState = self[row,col]
                switch cellState {
                case Player.white:
                    rtn += "X "
                case Player.black:
                    rtn += "0 "
                default:
                    rtn += "- "
                }
            }
            rtn += "\n"
        }
        return rtn
    }

    
    
    // row: goes from 1 ... NumberOfRows
    // column: goes from 1 ... NumberOfColumnes
    
    subscript(row: Int, column: Int) -> Player {
        get {
            return cells[row * (ConnectBoard.NumberOfColumnes + 2) + column]
        }
        set {
            cells[row * (ConnectBoard.NumberOfColumnes + 2) + column] = newValue
        }
    }

    
    
    fileprivate func postCellDidChangedNotification(row: Int, column: Int) {
        let userInfo = ["column": NSNumber(value: column as Int), "row" : NSNumber(value: row as Int)]
        NotificationCenter.default.post(name: Notification.Name(rawValue: ConnectBoard.CellDidChangeNotification), object: self,
            userInfo: userInfo)
    }
    
    
    
    fileprivate func postEndOfGameNotification(cellIndex: Int, direction: Int) {
        
        let row = cellIndex / (ConnectBoard.NumberOfColumnes + 2)
        let column = cellIndex % (ConnectBoard.NumberOfColumnes + 2)
        
        let userInfo = ["row" : NSNumber(value: row as Int), "column" : NSNumber(value: column as Int), "direction" : NSNumber(value: direction == 1 ? 1 : direction - 2 as Int) ]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: ConnectBoard.EndOfGameNotification), object: self,
            userInfo: userInfo)
        
    }
    

}

// convenience funtion used for testing
func ==(lhs: ConnectBoard, rhs: ConnectBoard) -> Bool {
    
    if lhs.cells.count != rhs.cells.count {
        return false
    }
    
    for i in 0..<lhs.cells.count  {
        if lhs.cells[i] != rhs.cells[i] {
            return false
        }
    }
    
    if  lhs.nextPlayer != rhs.nextPlayer ||
        lhs.isEndPosition != rhs.isEndPosition ||
        lhs.winner != rhs.winner {
        return false
    }
    
    for i in 0..<lhs.topRowIndexForColumn.count  {
        if lhs.topRowIndexForColumn[i] != rhs.topRowIndexForColumn[i] {
            return false
        }
    }
    
    return true
}


