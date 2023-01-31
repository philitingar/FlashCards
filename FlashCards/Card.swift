//
//  Card.swift
//  FlashCards
//
//  Created by Timi on 11/1/23.
//

import Foundation


struct Card: Codable  {
    let prompt: String
    let answer: String
    
    static let example = Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
}
