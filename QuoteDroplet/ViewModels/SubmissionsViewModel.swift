//
//  SubmissionsViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2026-11-02.
//

import Foundation

class SubmissionsViewModel: ObservableObject {
    @Published var submissions: [Submission] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    let apiService: IAPIService
    let submitterID: String

    init(apiService: IAPIService, submitterID: String = SubmitterIDService.getOrCreate()) {
        self.apiService = apiService
        self.submitterID = submitterID
    }

    public func getSubmissions() async -> Void {
        await MainActor.run {
            self.isLoading = true
        }

        let (submissions, error): ([Submission]?, Error?) = await withCheckedContinuation { continuation in
            apiService.getSubmissions(submitterID: submitterID) { submissions, error in
                continuation.resume(returning: (submissions, error))
            }
        }

        await MainActor.run {
            self.isLoading = false
            if let submissions = submissions {
                self.submissions = submissions
                self.errorMessage = nil
            } else {
                print("Error fetching submissions: \(String(describing: error))")
                self.errorMessage = "Couldn't load your submissions. Pull down to try again."
            }
        }
    }
}
