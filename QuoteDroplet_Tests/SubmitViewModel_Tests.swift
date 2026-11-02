//
//  SubmitViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet
import Foundation

@Suite("Submit View Model Tests", .serialized) final class SubmitViewModel_Tests {
    let mockAPIService: MockAPIService
    let sut: SubmitViewModel
	weak var weakSUT: SubmitViewModel?

    init() {
        self.mockAPIService = MockAPIService()
		self.sut = SubmitViewModel(apiService: mockAPIService)
		self.weakSUT = self.sut
	}

	deinit {
		// #expect(weakSUT == nil)
	}

    @Test func addQuote_successfulSubmission_updatesState() async {
        // Configure the mock service for a successful submission
        mockAPIService.setAddQuoteResponse(success: true, error: nil)

        sut.quoteText = "Inspire yourself daily."
        sut.author = "Anonymous"
        sut.selectedCategory = .inspiration

        await sut.addQuote()

        // Verify that submission was successful and state was updated correctly
        #expect(sut.submissionMessage == "Thanks for submitting a quote. It is now awaiting approval to be added to this app's quote database.")
        #expect(!sut.isAddingQuote)
        #expect(sut.showSubmissionReceivedAlert)

        // Verify fields are reset after submission
        #expect(sut.quoteText.isEmpty)
        #expect(sut.author.isEmpty)
        #expect(sut.selectedCategory == .wisdom)  // Assuming wisdom is the default category after reset
    }

    @Test func addQuote_failureSubmission_updatesErrorMessage() async {
        // Configure the mock service to simulate a failure
        let errorMessage = "Failed to submit quote due to network error."
        mockAPIService.setAddQuoteResponse(success: false, error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))

        sut.quoteText = "Test failure quote."
        sut.author = "Test Author"

        await sut.addQuote()

        // Verify that the submission failed, and error message was set
        #expect(sut.submissionMessage == errorMessage)
        #expect(!sut.isAddingQuote)
        #expect(sut.showSubmissionReceivedAlert)

        // Verify fields are reset after failure
        #expect(sut.quoteText.isEmpty)
        #expect(sut.author.isEmpty)
        #expect(sut.selectedCategory == .wisdom)  // Assuming wisdom is the default category after reset
    }
}
