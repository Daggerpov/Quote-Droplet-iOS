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
        
        if isLiked {
            likedQuotes.append(quote)
        } else {
            likedQuotes.removeAll { $0.id == quote.id }
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
        
        if isBookmarked {
            bookmarkedQuotes.append(quote)
        } else {
            bookmarkedQuotes.removeAll { $0.id == quote.id }
        }
        
        @AppStorage("bookmarkedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
        var bookmarkedQuotesData: Data = Data()
        if let data = try? JSONEncoder().encode(bookmarkedQuotes) {
            bookmarkedQuotesData = data
        }
    }
    
    
    func getRecentLocalQuotes() -> [Quote] {
        @AppStorage("recentQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
        var recentQuotesData: Data = Data()
        if let quotes = try? JSONDecoder().decode([Quote].self, from: recentQuotesData) {
            return quotes
        }
        return []
    }
    
    func saveRecentQuote(quote: Quote) -> Void {
        var recentQuotes = getRecentLocalQuotes()
        
        recentQuotes.append(quote)
        
        @AppStorage("recentQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
        var recentQuotesData: Data = Data()
        if let data = try? JSONEncoder().encode(recentQuotes) {
            recentQuotesData = data
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


