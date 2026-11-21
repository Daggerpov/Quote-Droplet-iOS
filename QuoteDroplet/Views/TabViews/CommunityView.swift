//
//  CommunityView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import Foundation

@available(iOS 16.0, *)
struct CommunityView: View {
    @StateObject var viewModel: CommunityViewModel = CommunityViewModel(
        localQuotesService: LocalQuotesService(), apiService: APIService()
    )
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                HeaderView(title: "Community", subtitle: "From readers")
                ScrollView {
                    VStack(spacing: 20) {
                        actionsSection
                        quoteSection
                    }
                    .padding(.horizontal, AppMetrics.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .modifier(MainScreenBackgroundStyling())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.getRecentQuotes()
                sharedVars.reloadFromDefaults()
            }
        }
    }
}

@available(iOS 16.0, *)
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .environmentObject(SharedVarsBetweenTabs())
    }
}

@available(iOS 16.0, *)
extension CommunityView {
    private var palette: AppPalette { sharedVars.palette }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Know a quote that belongs here?")
                .font(AppFont.sectionTitle)
                .foregroundColor(palette.text)
            Text("Submit it, and once it's approved it shows up for everyone, credited to you if you like.")
                .font(.subheadline)
                .foregroundColor(palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                SubmitView()
                mySubmissionsButton
            }
            .padding(.top, 4)
        }
        .modifier(CardStyling(padding: 20))
    }

    private var mySubmissionsButton: some View {
        NavigationLink {
            SubmissionsView()
        } label: {
            SubmitButtonView(text: "My Submissions", imageSystemName: "tray.full", isPrimary: false)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func communityQuoteRow(_ quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(quote.text)
                .modifier(QuoteTextStyling(font: .system(.body, design: .serif)))
            HStack(alignment: .firstTextBaseline) {
                if let approvedDate = quote.approvedDate {
                    Text("Added \(approvedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(palette.secondaryText)
                        .lineLimit(1)
                        .fixedSize()
                }
                Spacer(minLength: 12)
                if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
                    AuthorLink(author: author, quote: quote)
                }
            }
        }
        .padding(.vertical, 14)
    }

    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Newest quotes")
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.recentQuotes.isEmpty {
                    ForEach(0..<3, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 5).fill(palette.text.opacity(0.10)).frame(height: 12)
                            RoundedRectangle(cornerRadius: 5).fill(palette.text.opacity(0.10)).frame(width: 180, height: 12)
                        }
                        .padding(.vertical, 16)
                        if index < 2 {
                            Rectangle().fill(palette.hairline).frame(height: 1)
                        }
                    }
                } else {
                    ForEach(viewModel.recentQuotes, id: \.id) { quote in
                        communityQuoteRow(quote)
                        if quote.id != viewModel.recentQuotes.last?.id {
                            Rectangle().fill(palette.hairline).frame(height: 1)
                        }
                    }
                }
            }
            .modifier(CardStyling(padding: 18))
        }
    }
}
