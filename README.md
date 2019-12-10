# About SwiftGameBench #

SwiftGameBench is a simple two player board game framework implemented with the Swift language. It comes with  Connect4 App so you can learn how to use it and implement your own board games. GameBench framework provides an  alpha-beta search engine for game tree analysis. It uses a fix look ahead and does  not increase search level dynamically.

This project is the result of my Test-Driven-Development (TDD) experiment in November 2015 where I tried to implement the model and search engine completely with TDD. I implemented the project in three days not using the debugger a single time.

## Steps to create your own board game ##
You can implement your own board game in four steps:

1. Create your *Move* class
2. Create your *Board* class
3. Create your *BoardView* class
4. Create your *BoardViewController* class 

For the last two steps you can have a look at *ConnectBoardView* and *ConnectBoardViewController* Class samples. These samples give you a good understanding. The tricky part is to implement your own *Board* class that implements the following protocol:

```swift
public protocol Board  {    
    var validMoves: [Move] { get }
    var heuristicValue: Int { get }
    var nextPlayer: Player { get }
    var winner: Player { get }
    var isEndPosition: Bool { get }
    var isSearching: Bool { get set }

    func isValidMove(move: Move) -> Bool
    func doMove(move: Move)
    func undoMove(move: Move)
}
```

Especially the *heuristicValue* property needs special attention. It is used to evaluate a 
board position when the search engine has reached the search depth but the board is not
an end position. In this case the search engine needs a a hint if it is a good position for white (the maximizer) or black (the minimizer). Therefore return a large positive integer if the board represents a good position for white or a negative value if it is a better position for black. Your heuristic function can be high sophisticated but remember it must be evaluated thousands of times during search tree analysis. So this function's time complexity should be as good as possible. 

Another important property is the *validMoves*. It should  return all valid moves of the board. You can increase the search engine performance if you return the best move first - this is often not a simple task. Have a look at *ConnectBoard* class it will give you a good sample of how this can be done. 

And last but not least don't forget your Board Unit Tests. You will love it!

## Heuristic for Connect 4 ##
The used heuristic for *ConnectBoard* uses the fact that it is better to have a stone in the middle columns than on the edge columns. It uses the column weights *[10, 20, 40, 80, 40, 20, 10]* for each stone and takes the sum over all stones on the board  where a white stone has positiv weight and a black stone a negative one. This sum can be adjusted with only one addition for each move and is therefore very efficient!Thomas Kausch
