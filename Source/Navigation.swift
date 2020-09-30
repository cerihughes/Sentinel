//
//  Navigation.swift
//  Sentinel
//
//  Created by Ceri Hughes on 30/09/2020.
//

import Foundation

enum Navigation: Equatable {
    case intro
    case lobby
    case levelSummary(level: Int)
    case game(level: Int)

    // Debug
    case stagingArea
}
