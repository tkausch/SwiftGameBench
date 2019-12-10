//
//  Board.swift
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


/// The `Board` protocol defines common methods and properties  for any two player
/// game with full knowlege.
/// 
/// A board knows it's `validMoves`, the `nextPlayer` and the board value.
///
/// When implementing your own board class you have to implement this protocol and provide
/// efficient implementations for `do(move:)` and `undo(move:)`. The `heuristicValue` 
/// property should reflect if the board represents advantage position for black 
/// or white player. Good positons for the white player should have positiv values. 
/// If the board represents a winning position for white it must have 
/// the `Integer.max` value. This value is used from the `SearchEngine` to choose
/// the best move.
public protocol Board  {

    associatedtype MoveType: Move
    
    /// Returns all valid moves for current position.
    var validMoves: [MoveType] { get }
    
    /// Returns heuristic board value.
    var heuristicValue: Int { get }
    
    /// Returns player who is next to move.
    var nextPlayer: Player { get }
    
    /// Returns winner of the board or none if game is not yet finished.
    var winner: Player { get }
    
    /// Returns true if game is over, false otherwise.
    var isEndPosition: Bool { get }
    
    /// Returns true if board is searching.
    var isSearching: Bool { get set }
    
    /// Returns true if move is valid.
    func isValidMove(_ move: MoveType) -> Bool

    /// Executes move on current board.
    func doMove(_ move: MoveType)
    
    /// Undo move on current board.
    func undoMove(_ move: MoveType)
    
}
