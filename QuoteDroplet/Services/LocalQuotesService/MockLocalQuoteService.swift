//
//  MockLocalQuoteService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

class MockLocalQuotesService: ILocalQuotesService {
    // for testing manipulation:
    private var isBookmarked = false
    private var isLiked = false

    private var bookmarkedQuotes: [Quote] = [Quote]()

    func setIsBookmarked(_ bookmarked: Bool) {
        isBookmarked = bookmarked
    }

    func setIsLiked(_ liked: Bool) {
        isLiked = liked
    }


    func getLikedQuotes() -> [Quote] {
        return [Quote.mockQuote(), Quote.mockQuote()]
    }

    func saveLikedQuote(quote: Quote, isLiked: Bool) -> Void {
        self.isLiked = isLiked
    }

    func getBookmarkedQuotes() -> [Quote] {
        return [Quote.mockQuote(), Quote.mockQuote()]
    }

    func saveBookmarkedQuote(quote: Quote, isBookmarked: Bool) -> Void {
        return
    }

    private var customQuotes: [Quote] = [Quote]()

    func getCustomQuotes() -> [Quote] {
        return customQuotes
    }

    func saveCustomQuote(_ quote: Quote) -> Void {
        customQuotes.removeAll { $0.id == quote.id }
        customQuotes.append(quote)
    }

    func deleteCustomQuote(_ quote: Quote) -> Void {
        customQuotes.removeAll { $0.id == quote.id }
    }

    func loadQuotesFromJSON() -> [QuoteJSON] {
        return [QuoteJSON.mockQuote(), QuoteJSON.mockQuote()]
    }

    func isQuoteLiked(_ quote: Quote) -> Bool {
        return isLiked
    }

    func isQuoteBookmarked(_ quote: Quote) -> Bool {
        return isBookmarked
    }


}
