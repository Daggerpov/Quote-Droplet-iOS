//
//  FeedbackViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 4/25/25.
//

import Foundation

class FeedbackViewModel: ObservableObject {
    @Published var isSubmittingFeedback: Bool = false
    @Published var feedbackType: String = "General"
    @Published var submissionMessage: String = ""
    @Published var showSubmissionReceivedAlert: Bool = false
    @Published var showSubmissionInfoAlert: Bool = false
    @Published var feedbackText: String = ""
    @Published var contactEmail: String = ""
    
    let apiService: IAPIService
    
    init(apiService: IAPIService) {
        self.apiService = apiService
    }
    
    func submitFeedback() -> Void {
        self.isSubmittingFeedback = true
        apiService.sendFeedback(text: feedbackText, type: feedbackType, email: contactEmail) { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.submissionMessage = "Thanks for your feedback! I appreciate you taking the time to help improve Quote Droplet."
                self.feedbackText = ""
                self.contactEmail = ""
                self.feedbackType = "General"
            } else if let error = error {
                self.submissionMessage = error.localizedDescription
            } else {
                self.submissionMessage = "An unknown error occurred."
            }
            self.isSubmittingFeedback = false
            self.showSubmissionReceivedAlert = true
        }
    }
} 
