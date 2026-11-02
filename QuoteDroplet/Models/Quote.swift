//
//  Quote.swift
//  Quote-Droplet
//
//  Created by Daniel Agapov on 2023-04-05.
//

import Foundation

struct Quote: Codable, Identifiable, Equatable {
    let id: Int
    let text: String
    let author: String?
    let classification: String?
    let likes: Int?
    // Only returned by some endpoints (e.g. quotes/recent)
    var approvedAt: String? = nil

    var approvedDate: Date? {
        APIDateParser.date(from: approvedAt)
    }
}

// Parses the backend's RFC 3339 timestamps, which may or may not include fractional seconds
enum APIDateParser {
    static func date(from string: String?) -> Date? {
        guard let string = string else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}


extension Quote {
    static func mockQuote() -> Quote {
        let ids = [0, 10, 85]
        let likes = [0, 10, 30]

        let mockData = [
            (text: "Courage isn't having the strength to go on—it is going on when you don't have strength.",
             author: "Napoleon",
             classification: "motivation"),

            (text: "He who has a why to live can bear almost any how.",
             author: "Friedrich Nietzsche",
             classification: "philosophy"),

            (text: "If you are filled with pride, then you will have no room for wisdom.",
             author: "African Proverb",
             classification: "wisdom")
        ]

        let randomID = ids.randomElement()!
        let randomLikes = likes.randomElement()!
        let randomQuote = mockData.randomElement()!

        return Quote(
            id: randomID,
            text: randomQuote.text,
            author: randomQuote.author,
            classification: randomQuote.classification,
            likes: randomLikes
        )
    }
}

