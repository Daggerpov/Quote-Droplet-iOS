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

    func getRecentLocalQuotes() -> [Quote] {
        return [Quote.mockQuote(), Quote.mockQuote()]
    }

    func saveRecentQuote(quote: Quote) -> Void {
        return
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
