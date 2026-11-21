//
//  BookmarkHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-20.
//

import Foundation
import SwiftUI
import Foundation

class LocalQuotesService: ILocalQuotesService {
    func getLikedQuotes() -> [Quote] {
        @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
        var likedQuotesData: Data = Data()
        if let quotes = try? JSONDecoder().decode([Quote].self, from: likedQuotesData) {
            return quotes
        }
        return []
    }
    
    func saveLikedQuote(quote: Quote, isLiked: Bool) -> Void {
        var likedQuotes = getLikedQuotes()
        
        // Remove first so re-liking a quote never creates duplicates
        likedQuotes.removeAll { $0.id == quote.id }
        if isLiked {
            likedQuotes.append(quote)
        }
        
        @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
        var likedQuotesData: Data = Data()
        if let data = try? JSONEncoder().encode(likedQuotes) {
            likedQuotesData = data
        }
    }
    
    func getBookmarkedQuotes() -> [Quote] {
        @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
        var bookmarkedQuotesData: Data = Data()
        if let quotes = try? JSONDecoder().decode([Quote].self, from: bookmarkedQuotesData) {
            print("DEBUG: LocalQuotesService - Retrieved \(quotes.count) bookmarked quotes from UserDefaults")
            return quotes
        }
        print("DEBUG: LocalQuotesService - No bookmarked quotes found in UserDefaults")
        return []
    }
    
    func saveBookmarkedQuote(quote: Quote, isBookmarked: Bool) -> Void {

        var bookmarkedQuotes = getBookmarkedQuotes()
        
        // Remove first so re-saving a quote never creates duplicates
        bookmarkedQuotes.removeAll { $0.id == quote.id }
        if isBookmarked {
            bookmarkedQuotes.append(quote)
        }
        
        @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
        var bookmarkedQuotesData: Data = Data()
        if let data = try? JSONEncoder().encode(bookmarkedQuotes) {
            bookmarkedQuotesData = data
        }
    }
    
    
    /// The user's own quotes from the Custom tab, oldest first. Shared with the widget through the app group.
    func getCustomQuotes() -> [Quote] {
        guard let data = UserDefaults(suiteName: "group.selectedSettings")?.data(forKey: "customQuotes"),
              let quotes = try? JSONDecoder().decode([Quote].self, from: data) else {
            return []
        }
        return quotes
    }

    /// Adds a new custom quote, or replaces the one with the same ID (an edit).
    func saveCustomQuote(_ quote: Quote) -> Void {
        var quotes = getCustomQuotes()
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote
        } else {
            quotes.append(quote)
        }
        writeCustomQuotes(quotes)
    }

    func deleteCustomQuote(_ quote: Quote) -> Void {
        writeCustomQuotes(getCustomQuotes().filter { $0.id != quote.id })
    }

    private func writeCustomQuotes(_ quotes: [Quote]) {
        if let data = try? JSONEncoder().encode(quotes) {
            UserDefaults(suiteName: "group.selectedSettings")?.set(data, forKey: "customQuotes")
        }
    }

    func loadQuotesFromJSON() -> [QuoteJSON] {
        // Load quotes from JSON file
        guard let path = Bundle.main.path(forResource: "QuotesBackup", ofType: "json") else {
            print("Error: Unable to locate quotes.json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            return try decoder.decode([QuoteJSON].self, from: data) // quotes
        } catch {
            print("Error decoding quotes JSON: \(error.localizedDescription)")
        }
        return []
    }
    
    func isQuoteLiked(_ quote: Quote) -> Bool {
        return getLikedQuotes().contains(where: { $0.id == quote.id })
    }
    
    func isQuoteBookmarked(_ quote: Quote) -> Bool {
        return getBookmarkedQuotes().contains(where: { $0.id == quote.id })
    }
    
}


