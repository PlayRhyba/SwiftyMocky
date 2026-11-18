//
//  ProtocolsWithClosures.swift
//  Mocky_Example
//
//  Created by Andrzej Michnia on 17.11.2017.
//  Copyright © 2017 MakeAWishFoundation. All rights reserved.
//

import Foundation

//sourcery: AutoMockable
protocol ProtocolWithClosures {
    func methodThatTakes(closure: (Int) -> Int)
    func methodThatTakesEscaping(closure: @escaping (Int) -> Int)
    func methodThatTakesCompletionBlock(completion: (Bool,(any Error)?) -> Void)
}
