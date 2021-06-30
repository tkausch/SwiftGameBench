//
//  ConnectBoardViewController.swift
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
import SwiftGameBenchFramework

class ConnectBoardViewController: UIViewController {
    
    @IBOutlet weak var connectBoardView: ConnectBoardView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    
    @IBOutlet weak var levelSlider: UISlider!
    
    fileprivate let board = ConnectBoard()
    fileprivate let searchEngine = AlphaBetaSearchEngine<ConnectBoard>()
    
    
    fileprivate var level : UInt = 3
    fileprivate var moves : [ConnectMove] = []
    

    //MARK: - UIViewController methods
    
    override func viewDidLoad() {
        
        connectBoardView.delegate = self
        connectBoardView.board = board
        
        levelSlider.maximumValue = 6.0
        levelSlider.minimumValue = 1.0
        levelSlider.value = 3.0
        
        updateMessageWithHint("Touch a column to move!\nYou are the red player.")
        updateButtons()
        
        super.viewDidLoad()
        
    }
    
    
    //MARK: Game control methods
    
    func updateButtons() {
        undoButton.isEnabled = !board.isEndPosition && moves.count > 0 && board.nextPlayer == Player.white && moves.count != 0
        
        newGameButton.isEnabled = moves.count > 0
    }
    
    
    func updateMessageWithHint(_ hint: String?) {
        
        if !board.isEndPosition {
            if board.nextPlayer == .black {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
        } else {
            activityIndicatorView.stopAnimating()
        }
        
        updateBottomLabelWithHint(hint)
    }
    
    

    func updateBottomLabelWithHint(_ hint: String?) {
        
        let prefix = hint != nil ? hint! + "\n" : ""
        if board.isEndPosition {
            
            if board.winner == Player.none {
                messageLabel.text =  prefix + "Drawn Game!"
            } else {
                let winnerName = nameForPlayer(board.winner)
                messageLabel.text = prefix + "Game is over!\n \(winnerName) is the winner."
            }
        } else {
            
            let nextPlayerName = nameForPlayer(board.nextPlayer)
            messageLabel.text = prefix + "It is \(nextPlayerName)'s turn."
        }
    }
    


    
    func computeNextMove() {
        
        assert(!self.board.isEndPosition && self.board.nextPlayer == .black, "Game is not over and computer is moving")
        
        updateMessageWithHint("Computer is moving.")
        
        connectBoardView.isUserInteractionEnabled = false
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.connectBoardView.disableUpdates = true
            let (bestMove, _ )  = self.searchEngine.bestMoveForBoard(self.board, searchDepth: self.level)
            self.connectBoardView.disableUpdates = false
            DispatchQueue.main.async {
                self.board.doMove(bestMove!)
                self.moves.append(bestMove!)
                self.updateButtons()
                self.updateMessageWithHint(nil)
                self.connectBoardView.isUserInteractionEnabled = true
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }
        }
    }

    
    func nameForPlayer(_ player: Player) -> NSString {
        switch (player) {
        case .white:
            return "Red"
        case .black:
            return "Black"
        default:
            return "none"
            
        }
        
    }
        
    //MARK: - IBAction methods

    @IBAction func undoMove(_ sender: UIButton) {
        if !board.isEndPosition && moves.count >= 2 {
            for _ in 0...1 {
                let lastMove = moves.removeLast()
                board.undoMove(lastMove)
            }
            updateMessageWithHint("Took back last two moves!")
            updateButtons()
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        board.reset()
        connectBoardView.reset()
        moves = []
        
        updateMessageWithHint("Next try!\nYou are red player again.")
        updateButtons()
        
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        level = UInt(sender.value)
        updateMessageWithHint("Set Level to \(level)")
        
    }

}


extension ConnectBoardViewController: ConnectBoardViewDelegate {
    
    
    func didSelectColumn(_ column: Int) {
        if let move = board.moveForColumn(column + 1) {
            board.doMove(move)
            moves.append(move)
            updateButtons()
            updateMessageWithHint(nil)
            if !board.isEndPosition && board.nextPlayer  == .black {
                computeNextMove()
            }
        } else {
            if board.isEndPosition {
                updateMessageWithHint("You can't move!")
            } else {
                // move was nil - means column was invalid
                updateMessageWithHint("Select another column!")
            }
        }
    }
    
}

