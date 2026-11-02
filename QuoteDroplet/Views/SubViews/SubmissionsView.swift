//
//  SubmissionsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2026-11-02.
//

import SwiftUI

@available(iOS 16.0, *)
struct SubmissionsView: View {
    @StateObject var viewModel: SubmissionsViewModel = SubmissionsViewModel(apiService: APIService())
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    var body: some View {
        ScrollView {
            VStack {
                submissionsSection
            }
            .padding()
        }
        .modifier(MainScreenBackgroundStyling())
        .refreshable {
            await viewModel.getSubmissions()
        }
        .task {
            await viewModel.getSubmissions()
        }
    }
}

@available(iOS 16.0, *)
struct SubmissionsView_Previews: PreviewProvider {
    static var previews: some View {
        SubmissionsView()
    }
}

@available(iOS 16.0, *)
extension SubmissionsView {
    private var submissionsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("My Submissions")
                    .modifier(QuotesPageTitleStyling())
                Spacer()
            }

            if viewModel.submissions.isEmpty {
                if viewModel.isLoading {
                    Text("Loading Submissions ...")
                        .modifier(CommunityQuotesTextStyling())
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .modifier(CommunityQuotesTextStyling())
                } else {
                    Text("You haven't submitted any quotes from this device yet. Quotes you submit will show up here along with their approval status.")
                        .modifier(CommunityQuotesTextStyling())
                }
            } else {
                ForEach(viewModel.submissions) { submission in
                    submissionRow(submission)
                    if submission != viewModel.submissions.last {
                        Divider()
                            .background(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                    }
                }
            }
        }
        .modifier(QuotesSectionOuterStyling())
    }

    private func submissionRow(_ submission: Submission) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(submission.text)
                    .modifier(CommunityQuotesTextStyling())
                Spacer()
            }

            if let author = submission.author, isAuthorValid(authorGiven: submission.author) {
                HStack {
                    Spacer()
                    Text("— \(author)")
                        .modifier(CommunityQuotesAuthorTextStyling())
                }
            }

            HStack {
                statusBadge(submission.submissionStatus)
                Spacer()
                if let date = submission.submittedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.footnote)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                }
            }
        }
        .padding(.vertical, 5)
    }

    private func statusBadge(_ status: SubmissionStatus) -> some View {
        HStack(spacing: 4) {
            Image(systemName: status.imageSystemName)
            Text(status.displayName)
        }
        .font(.footnote.bold())
        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .stroke(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue, lineWidth: 1.5)
        )
    }
}
