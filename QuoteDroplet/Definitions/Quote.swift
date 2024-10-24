//
//  Quote.swift
//  Quote-Droplet
//
//  Created by Daniel Agapov on 2023-04-05.
//

import Foundation

struct Quote: Codable, Identifiable {
    let id: Int
    let text: String
    let author: String?
    let classification: String?
    let likes: Int?
}
