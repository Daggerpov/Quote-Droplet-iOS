//
//  CommunityViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet
import Foundation

@Suite("Community View Model Tests", .serialized) final class CommunityViewModel_Tests {

    let mockAPIService: MockAPIService
    let sut: CommunityViewModel
	weak var weakSUT: CommunityViewModel?

    init() {
        self.mockAPIService = MockAPIService()
		self.sut = CommunityViewModel(localQuotesService: MockLocalQuotesService(), apiService: mockAPIService)
		self.weakSUT = self.sut
	}

	deinit {
		// #expect(weakSUT == nil)
	}

    @Test func getRecentQuotes_success() async throws {
        let firstMockQuote: Quote = Quote.mockQuote()
        let mockQuotes = [
            firstMockQuote,
            Quote.mockQuote(),
            Quote.mockQuote()
        ]

        mockAPIService.setRecentQuotesResponse(quotes: mockQuotes, error: nil)

        sut.getRecentQuotes()

        #expect(sut.recentQuotes.count == 3)
        #expect(sut.recentQuotes.contains(firstMockQuote))
    }

    @Test func getRecentQuotes_failure() async throws {
        let mockError = NSError(domain: "TestError", code: 404, userInfo: nil)
        mockAPIService.setRecentQuotesResponse(quotes: nil, error: mockError)

        sut.getRecentQuotes()

        #expect(sut.recentQuotes.isEmpty)
    }

    @Test func quote_decodesApprovedAt() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let json = Data("""
        [
            {"id": 1, "text": "With date", "author": "A", "classification": "wisdom", "likes": 3, "approved_at": "2026-06-27T07:34:54.931084Z"},
            {"id": 2, "text": "Without date", "author": "B", "classification": "wisdom", "likes": 4}
        ]
        """.utf8)

        let quotes = try decoder.decode([Quote].self, from: json)

        #expect(quotes[0].approvedDate != nil)
        #expect(quotes[1].approvedAt == nil)
        #expect(quotes[1].approvedDate == nil)
    }
}
