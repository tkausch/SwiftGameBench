//
//  Player.swift
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


public enum Player : Int, CustomStringConvertible {

    case white = 1, black = -1, none = 0
    
    public func oponent() -> Player {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        case .none:
            return .none
        }
    }
    
    public var description: String {
        switch self {
        case .white:
            return "White"
        case .black:
            return "Black"
        case .none:
            return "None"
        }
    }
    
}
