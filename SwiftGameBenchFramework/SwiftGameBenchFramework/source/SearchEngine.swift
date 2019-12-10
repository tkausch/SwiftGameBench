//
//  SearchEngine
//  SwiftGameBench
//
//  Created by Thomas Kausch on 01/08/17.
//  Copyright © 2016 Swisscom. All rights reserved.
//

import Foundation

public protocol SearchEngine {
    
    associatedtype BoardType: Board
    
    var numberOfVisitedBoards: UInt { get }
    
    func bestMoveForBoard(_ board: BoardType, searchDepth: UInt ) -> (move: BoardType.MoveType?, boardValue: Int)
    
}
