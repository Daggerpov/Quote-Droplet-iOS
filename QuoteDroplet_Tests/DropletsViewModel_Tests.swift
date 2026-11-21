//
//  DropletsViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Droplets View Model Tests", .serialized) final class DropletsViewModel_Tests {
    let mockAPIService: MockAPIService
    let sut: DropletsViewModel
	weak var weakSUT: DropletsViewModel?
    init() {
        self.mockAPIService = MockAPIService()
        self.sut = DropletsViewModel(
            localQuotesService: MockLocalQuotesService(),
            apiService: mockAPIService
        )
		self.weakSUT = self.sut
    }

	deinit {
		// #expect(weakSUT == nil)
	}

    @Test func setSelected() {
        #expect(sut.selected == SelectedPage.feed)
        sut.setSelected(newValue: SelectedPage.custom)
        #expect(sut.selected == SelectedPage.custom)
        sut.setSelected(newValue: SelectedPage.saved)
        #expect(sut.selected == SelectedPage.saved)
    }

    @Test func getTitleText() {
        sut.setSelected(newValue: SelectedPage.feed)
        #expect(sut.getTitleText() == "Quotes Feed")
        sut.setSelected(newValue: SelectedPage.saved)
        #expect(sut.getTitleText() == "Saved Quotes")
        sut.setSelected(newValue: SelectedPage.custom)
        #expect(sut.getTitleText() == "Custom Quotes")
    }

    @Test func customQuotes_addEditDelete() {
        #expect(sut.customQuotes.isEmpty)
        #expect(!sut.saveCustomQuote(text: "   ", author: "Nobody"))
        #expect(sut.customQuotes.isEmpty)

        #expect(sut.saveCustomQuote(text: "  Be kind.  ", author: " Mom "))
        #expect(sut.customQuotes.count == 1)
        let added = sut.customQuotes[0]
        #expect(added.text == "Be kind.")
        #expect(added.author == "Mom")
        #expect(added.isCustom)
        #expect(added.id < 0)

        #expect(sut.saveCustomQuote(text: "Be very kind.", author: "", editing: added))
        #expect(sut.customQuotes.count == 1)
        #expect(sut.customQuotes[0].id == added.id)
        #expect(sut.customQuotes[0].text == "Be very kind.")
        #expect(sut.customQuotes[0].author == nil)

        sut.deleteCustomQuote(sut.customQuotes[0])
        #expect(sut.customQuotes.isEmpty)
    }

    @Test func customCategory_isOnDeviceOnly() {
        #expect(QuoteCategory.custom.isOnDevice)
        #expect(QuoteCategory.bookmarkedQuotes.isOnDevice)
        #expect(!QuoteCategory.remoteCases.contains(.custom))
        #expect(!QuoteCategory.remoteCases.contains(.bookmarkedQuotes))
        #expect(QuoteCategory.remoteCases.contains(.wisdom))
    }

    /*
    @Test func loadInitialQuotes() async throws {
        #expect(sut.quotes.isEmpty)
        #expect(sut.savedQuotes.isEmpty)
        #expect(sut.customQuotes.isEmpty)

        let mockQuotes = [Quote.mockQuote(), Quote.mockQuote()]
        mockApiService.setQuoteByIDResponse(quotes: mockQuotes, error: nil)

        sut.loadInitialQuotes()

        #expect(sut.quotes.count > 0)
        #expect(sut.quotes.count <= sut.quotesPerPage)
    }
     */

    @Test func checkMoreQuotesNeeded() async throws {
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: DropletsViewModel.maxQuotes - 1)
        #expect(!sut.checkLimitReached())

        sut.checkMoreQuotesNeeded()

        #expect(sut.quotes.count > 0)
        #expect(sut.quotes.count <= DropletsViewModel.maxQuotes)
    }

    @Test func getPageSpecificQuotes_feed() {
        sut.setSelected(newValue: .feed)
        sut.quotes = [Quote.mockQuote(), Quote.mockQuote()]

        #expect(sut.getPageSpecificQuotes().count == sut.quotes.count)
    }

    @Test func getPageSpecificQuotes_saved() {
        sut.setSelected(newValue: .saved)
        sut.savedQuotes = [Quote.mockQuote(), Quote.mockQuote()]

        #expect(sut.getPageSpecificQuotes().count == sut.savedQuotes.count)
    }

    @Test func removeSavedQuote() {
        let keptQuote = Quote(id: 1, text: "Kept", author: nil, classification: nil, likes: nil)
        let removedQuote = Quote(id: 2, text: "Removed", author: nil, classification: nil, likes: nil)
        sut.savedQuotes = [keptQuote, removedQuote]

        sut.removeSavedQuote(removedQuote)

        #expect(sut.savedQuotes == [keptQuote])
    }

    @Test func checkLimitReached() {
        sut.setSelected(newValue: .feed)
        sut.quotes = [Quote](repeating: Quote.mockQuote(), count: DropletsViewModel.maxQuotes)

        #expect(sut.checkLimitReached())
    }

    @Test func getPageSpecificEmptyText() {
        sut.setSelected(newValue: .saved)
        let emptyText = sut.getPageSpecificEmptyText()

        #expect(emptyText == "You have no saved quotes. \n\nPlease save some from the Quotes Feed by pressing this:")
    }
}
