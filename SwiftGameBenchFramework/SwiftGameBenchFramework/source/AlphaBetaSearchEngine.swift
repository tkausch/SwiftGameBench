//
//  AlphaBetaSearchEngine.swift
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

public class AlphaBetaSearchEngine<B: Board>: SearchEngine {
    
    var nmbVisitedBoards: UInt
    var nmbOfAlphaBetaCuts: UInt
    
    public init() {
        nmbVisitedBoards = 0
        nmbOfAlphaBetaCuts = 0
    }
    
    public var numberOfVisitedBoards: UInt {
        return nmbVisitedBoards
    }
    
    public func bestMoveForBoard( _ board: B, searchDepth: UInt ) -> (move: B.MoveType?, boardValue: Int) {
        var board = board
        
        nmbVisitedBoards = 0
        
        board.isSearching = true
        
        let result = search(board, depth: searchDepth, alpha: Int.min, beta: Int.max)
        
        board.isSearching = false
        
        print("NumberOfVisitedBoards = \(numberOfVisitedBoards)")
        
        return result
        
    }
    
    
    
    public func search(_ board: B, depth: UInt, alpha: Int, beta: Int) -> (move: B.MoveType?, boardValue: Int) {
        var alpha = alpha, beta = beta
        
        self.nmbVisitedBoards += 1
        
        if board.isEndPosition || depth == 0 {
            return (nil, board.heuristicValue)
        } else {
            
            // Precondition: There are valid moves and search depth is greater zero
            
            if board.nextPlayer == Player.white {
                
                // Maximizer (white) is moving
                var maxBoardValue = Int.min
                var maxMove = board.validMoves[0]
                
                for move in board.validMoves {
                    board.doMove(move)
                    let nextMove = search(board, depth: depth - 1, alpha: alpha, beta: beta)
                    
                    if nextMove.boardValue >= maxBoardValue {
                        maxMove = move
                        maxBoardValue = nextMove.boardValue
                        alpha = max(alpha, maxBoardValue)
                    }
                    
                    board.undoMove(move)
                    
                    // Interrupt validMove iteration if current move
                    // is greater than the best move value of my father Minimizer node (beta).
                    // The minimizer would NOT choose  this path in game tree!
                    if maxBoardValue > beta {
                        return (maxMove, maxBoardValue)
                    }
                    
                }
                
                return (maxMove, maxBoardValue)
                
                
            } else {
                
                // Minimizer (black) is moving
                var minBoardValue = Int.max
                var minMove = board.validMoves[0]
                
                for move in board.validMoves {
                    board.doMove(move)
                    let nextMove = search(board, depth: depth - 1, alpha: alpha, beta: beta)
                    
                    if nextMove.boardValue <= minBoardValue {
                        minMove = move
                        minBoardValue = nextMove.boardValue
                        beta = min(beta, minBoardValue)
                    }
                    
                    board.undoMove(move)
                    
                    // Interrupt validMove iteration if current move value
                    // is smaller than the current move value of my father Maximizer node (alpha).
                    // The minimizer would NOT choose this path in game tree!
                    if minBoardValue < alpha {
                        return (minMove, minBoardValue)
                    }
                    
                }
                
                return (minMove, minBoardValue)
                
                
            }
            
        }
        
    }
    
    
    
    
}
