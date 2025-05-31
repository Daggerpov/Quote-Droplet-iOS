//
//  IAPIService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-26.
//

protocol IAPIService {
    func getRandomQuoteByClassification(
        classification: String,
        completion: @escaping (
            Quote?,
            Error?
        ) -> Void,
        isShortQuoteDesired: Bool
    ) -> Void
    func getQuotesByAuthor(
        author: String,
        completion: @escaping (
            [Quote]?,
            Error?
        ) -> Void
    ) -> Void
    func getQuotesBySearchKeyword(
        searchKeyword: String,
        searchCategory: String,
        completion: @escaping (
            [Quote]?,
            Error?
        ) -> Void
    ) -> Void
    func getRecentQuotes(
        limit: Int,
        completion: @escaping (
            [Quote]?,
            Error?
        ) -> Void
    ) -> Void
    func addQuote(
        text: String,
        author: String?,
        classification: String,
        submitterName: String?,
        completion: @escaping (
            Bool,
            Error?
        ) -> Void
    ) -> Void
    func sendFeedback(
        text: String,
        type: String,
        email: String,
        completion: @escaping (
            Bool,
            Error?
        ) -> Void
    ) -> Void
    func likeQuote(
        quoteID: Int,
        completion: @escaping (
            Quote?,
            Error?
        ) -> Void
    ) -> Void
    func unlikeQuote(
        quoteID: Int,
        completion: @escaping (
            Quote?,
            Error?
        ) -> Void
    ) -> Void
    func likeQuoteAsync(
        quoteID: Int
    ) async throws -> Quote?
    func unlikeQuoteAsync(
        quoteID: Int
    ) async throws -> Quote?
    func getQuoteByID(
        id: Int,
        completion: @escaping (
            Quote?,
            Error?
        ) -> Void
    ) -> Void
    func getCountForCategory(
        category: QuoteCategory,
        completion: @escaping (
            Int
        ) -> Void
    ) -> Void
    func getTopQuotes(
        category: QuoteCategory,
        completion: @escaping (
            [Quote]?,
            Error?
        ) -> Void
    ) -> Void
}
