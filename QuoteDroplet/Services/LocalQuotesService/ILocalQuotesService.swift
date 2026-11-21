//
//  ILocalQuotesService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

protocol ILocalQuotesService {
    func getLikedQuotes() -> [Quote]
    func saveLikedQuote(quote: Quote, isLiked: Bool) -> Void
    func getBookmarkedQuotes() -> [Quote]
    func saveBookmarkedQuote(quote: Quote, isBookmarked: Bool) -> Void
    func getCustomQuotes() -> [Quote]
    func saveCustomQuote(_ quote: Quote) -> Void
    func deleteCustomQuote(_ quote: Quote) -> Void
    func loadQuotesFromJSON() -> [QuoteJSON]
    func isQuoteLiked(_ quote: Quote) -> Bool
    func isQuoteBookmarked(_ quote: Quote) -> Bool
}
