//
//  MockAPIService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

class MockAPIService: IAPIService {

    // MARK: - Random Quote Response
    private var randomQuoteResponse: (Quote?, Error?)?
    func setRandomQuoteResponse(quote: Quote?, error: Error?) {
        randomQuoteResponse = (quote, error)
    }

    func getRandomQuoteByClassification(
        classification: String,
        completion: @escaping (Quote?, (any Error)?) -> Void,
        isShortQuoteDesired: Bool
    ) {
        completion(randomQuoteResponse?.0, randomQuoteResponse?.1)
    }

    // MARK: - Quotes by Author Response
    private var quotesByAuthorResponse: ([Quote]?, Error?)?
    func setQuotesByAuthorResponse(quotes: [Quote]?, error: Error?) {
        quotesByAuthorResponse = (quotes, error)
    }

    func getQuotesByAuthor(
        author: String,
        completion: @escaping ([Quote]?, (any Error)?) -> Void
    ) {
        completion(quotesByAuthorResponse?.0, quotesByAuthorResponse?.1)
    }

    // MARK: - Quotes by Search Keyword Response
    private var quotesBySearchResponse: ([Quote]?, Error?)?
    func setQuotesBySearchResponse(quotes: [Quote]?, error: Error?) {
        quotesBySearchResponse = (quotes, error)
    }

    func getQuotesBySearchKeyword(
        searchKeyword: String,
        searchCategory: String,
        completion: @escaping ([Quote]?, (any Error)?) -> Void
    ) {
        completion(quotesBySearchResponse?.0, quotesBySearchResponse?.1)
    }

    // MARK: - Recent Quotes Response
    private var recentQuotesResponse: ([Quote]?, Error?)?
    func setRecentQuotesResponse(quotes: [Quote]?, error: Error?) {
        recentQuotesResponse = (quotes, error)
    }

    func getRecentQuotes(
        limit: Int,
        completion: @escaping ([Quote]?, (any Error)?) -> Void
    ) {
        completion(recentQuotesResponse?.0, recentQuotesResponse?.1)
    }

    // MARK: - Add Quote Response
    private var addQuoteResponse: (Bool, Error?)?
    func setAddQuoteResponse(success: Bool, error: Error?) {
        addQuoteResponse = (success, error)
    }

    func addQuote(
        text: String,
        author: String?,
        classification: String,
        completion: @escaping (Bool, (any Error)?) -> Void
    ) {
        completion(addQuoteResponse?.0 ?? false, addQuoteResponse?.1)
    }

    // MARK: - Like Quote Response
    private var likeQuoteResponse: (Quote?, Error?)?
    func setLikeQuoteResponse(quote: Quote?, error: Error?) {
        likeQuoteResponse = (quote, error)
    }
    private var likeCount = 0

    func setLikeCount(_ count: Int) {
        likeCount = count
    }

    func likeQuote(
        quoteID: Int,
        completion: @escaping (Quote?, (any Error)?) -> Void
    ) {
        completion(likeQuoteResponse?.0, likeQuoteResponse?.1)
    }

    // MARK: - Unlike Quote Response
    private var unlikeQuoteResponse: (Quote?, Error?)?
    func setUnlikeQuoteResponse(quote: Quote?, error: Error?) {
        unlikeQuoteResponse = (quote, error)
    }

    func unlikeQuote(
        quoteID: Int,
        completion: @escaping (Quote?, (any Error)?) -> Void
    ) {
        completion(unlikeQuoteResponse?.0, unlikeQuoteResponse?.1)
    }

    // MARK: - Quote by ID Response
    private var quoteByIDResponse: (Quote?, Error?)?
    func setQuoteByIDResponse(quote: Quote?, error: Error?) {
        quoteByIDResponse = (quote, error)
    }

    func getQuoteByID(
        id: Int,
        completion: @escaping (Quote?, (any Error)?) -> Void
    ) {
        completion(quoteByIDResponse?.0, quoteByIDResponse?.1)
    }

    // MARK: - Like Count for Quote Response
    private var likeCountResponse: Int?
    func setLikeCountResponse(count: Int) {
        likeCountResponse = count
    }

    func getLikeCountForQuote(
        quoteGiven: Quote,
        completion: @escaping (Int) -> Void
    ) {
        completion(likeCountResponse ?? 0)
    }

    // MARK: - Count for Category Response
    private var countForCategoryResponse: Int?
    func setCountForCategoryResponse(count: Int) {
        countForCategoryResponse = count
    }

    func getCountForCategory(
        category: QuoteCategory,
        completion: @escaping (Int) -> Void
    ) {
        completion(countForCategoryResponse ?? 0)
    }
}
