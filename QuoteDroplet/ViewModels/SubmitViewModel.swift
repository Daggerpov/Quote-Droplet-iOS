//
//  SubmitViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

class SubmitViewModel: ObservableObject {
    @Published var isAddingQuote: Bool = false
    @Published var selectedCategory: QuoteCategory = .all
    @Published var submissionMessage: String = ""
    @Published var showSubmissionReceivedAlert: Bool = false
    @Published var showSubmissionInfoAlert: Bool = false
    @Published var quoteText: String = ""
    @Published var author: String = ""
    @Published var submitterName: String = ""
    
    let apiService: IAPIService
    
    init (apiService: IAPIService) {
        self.apiService = apiService
    }
    
    func addQuote() -> Void {
        apiService.addQuote(text: quoteText, author: author, classification: selectedCategory.rawValue, submitterName: submitterName) { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.submissionMessage = "Thanks for submitting a quote. It is now awaiting approval to be added to this app's quote database."
                // Set showSubmissionReceivedAlert to true after successful submission
            } else if let error = error {
                self.submissionMessage = error.localizedDescription
            } else {
                self.submissionMessage = "An unknown error occurred."
            }
            self.isAddingQuote = false
            self.showSubmissionReceivedAlert = true // <-- Set to true after successful submission
        }
        self.quoteText = ""
        self.author = ""
        self.submitterName = ""
        self.selectedCategory = .wisdom
    }
}
