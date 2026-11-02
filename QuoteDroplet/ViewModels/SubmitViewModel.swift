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
    // Remembered between submissions and app launches, so users don't retype their name each time
    @Published var submitterName: String {
        didSet {
            userDefaults.set(submitterName, forKey: Self.submitterNameKey)
        }
    }
    
    static let submitterNameKey = "submitterName"
    
    let apiService: IAPIService
    private let userDefaults: UserDefaults
    
    init (apiService: IAPIService, userDefaults: UserDefaults = .standard) {
        self.apiService = apiService
        self.userDefaults = userDefaults
        self.submitterName = userDefaults.string(forKey: Self.submitterNameKey) ?? ""
    }
    
    func addQuote() async -> Void {
        apiService.addQuote(text: quoteText, author: author, classification: selectedCategory.rawValue, submitterName: submitterName) { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
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
        }
        await MainActor.run {
            self.quoteText = ""
            self.author = ""
            self.selectedCategory = .wisdom
        }
    }
}
