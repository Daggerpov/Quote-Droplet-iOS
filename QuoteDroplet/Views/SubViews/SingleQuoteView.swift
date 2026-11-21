//
//  SingleQuoteview.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-09-08.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

@available(iOS 16.0, *)
struct SingleQuoteView: View {
    // StateObject so the view model (and its like/bookmark state) survives parent re-renders
    @StateObject var viewModel: SingleQuoteViewModel
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @State private var showCopiedCheck = false

    var quote: Quote
    var from: SingleQuoteSource
    var searchText: String?
    var onBookmarkRemoved: (() -> Void)?
    // Custom quotes show edit and delete in place of like and save
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    init(quote: Quote, from: SingleQuoteSource, searchText: String? = "", onBookmarkRemoved: (() -> Void)? = nil,
         onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.quote = quote
        self.from = from
        self.searchText = searchText
        self.onBookmarkRemoved = onBookmarkRemoved
        self.onEdit = onEdit
        self.onDelete = onDelete
        self._viewModel = StateObject(wrappedValue: SingleQuoteViewModel(
            localQuotesService: LocalQuotesService(),
            apiService: APIService(), quote: quote, from: from))
    }

    private var palette: AppPalette { sharedVars.palette }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(palette.accent.opacity(0.7))
            quoteTextView
            authorTextView
            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)
                .padding(.top, 2)
            quoteInteractionButtons
        }
        .modifier(CardStyling(padding: 20))
        .padding(.horizontal, AppMetrics.screenPadding)
        .onAppear {
            viewModel.getQuoteInfo()
        }
    }
}

@available(iOS 16.0, *)
extension SingleQuoteView {
    private func highlighted(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        let searchTextLowercased = (searchText ?? "").lowercased()
        guard !searchTextLowercased.isEmpty else { return attributedString }
        let textLowercased = text.lowercased()
        var searchStartIndex = textLowercased.startIndex

        // Loop to find and highlight all occurrences
        while let range = textLowercased.range(of: searchTextLowercased, range: searchStartIndex..<textLowercased.endIndex) {
            // Convert String.Index to AttributedString.Index
            if let attributedRange = Range(NSRange(range, in: textLowercased), in: attributedString) {
                attributedString[attributedRange].backgroundColor = palette.accent.opacity(0.32)
            }
            // Move searchStartIndex to the end of the found range to continue searching
            searchStartIndex = range.upperBound
        }

        return attributedString
    }

    private var quoteTextView: some View {
        Text(highlighted(quote.text))
            .modifier(QuoteTextStyling())
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var authorTextView: some View {
        if let author: String = quote.author, isAuthorValid(authorGiven: quote.author) {
            HStack(spacing: 4) {
                Spacer()
                if viewModel.shouldShowArrow() {
                    NavigationLink(destination: AuthorView(quote: viewModel.quote)) {
                        HStack(spacing: 4) {
                            Text(AttributedString("— ") + highlighted(author))
                                .modifier(AuthorTextStyling())
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundColor(palette.accent.opacity(0.8))
                        }
                    }
                    .buttonStyle(PressableButtonStyle())
                } else {
                    Text(AttributedString("— ") + highlighted(author))
                        .modifier(AuthorTextStyling())
                }
            }
        }
    }

    private func actionIcon(_ systemName: String, active: Bool = false) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(active ? palette.accent : palette.secondaryText)
            .frame(width: 36, height: 32)
            .contentShape(Rectangle())
    }

    private var quoteInteractionButtons: some View {
        let authorForSharing = (isAuthorValid(authorGiven: quote.author)) ? quote.author : ""
        let wholeAuthorText = (authorForSharing != "") ? "\n— \(authorForSharing ?? "Unknown Author")" : ""

        return HStack(spacing: 6) {
            if quote.isCustom {
                customQuoteButtons
            } else {
                likeAndSaveButtons
            }

            Button(action: {
                UIPasteboard.general.setValue("\(quote.text)\(wholeAuthorText)",
                                              forPasteboardType: UTType.plainText.identifier)
                viewModel.toggleCopy(for: quote)
                withAnimation(.easeOut(duration: 0.15)) { showCopiedCheck = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.easeOut(duration: 0.2)) { showCopiedCheck = false }
                }
            }) {
                actionIcon(showCopiedCheck ? "checkmark" : "doc.on.doc", active: showCopiedCheck)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Copy")

            Spacer()

            if let url = URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603") {
                ShareLink(item: url, message: Text("From the Quote Droplet app:\n\n\"\(quote.text)\"\(wholeAuthorText)")) {
                    actionIcon("square.and.arrow.up")
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Share")
            }
        }
    }

    @ViewBuilder
    private var customQuoteButtons: some View {
        if let onEdit = onEdit {
            Button(action: onEdit) {
                actionIcon("pencil")
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Edit")
        }
        if let onDelete = onDelete {
            Button(action: onDelete) {
                actionIcon("trash")
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Delete")
        }
    }

    @ViewBuilder
    private var likeAndSaveButtons: some View {
        Button(action: {
            viewModel.toggleLike(for: quote)
        }) {
            HStack(spacing: 2) {
                actionIcon(viewModel.isLiked ? "heart.fill" : "heart", active: viewModel.isLiked)
                // The like count next to the heart button
                Text("\(viewModel.likes)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundColor(viewModel.isLiked ? palette.accent : palette.secondaryText)
                    .padding(.trailing, 6)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(viewModel.isLiked ? "Unlike" : "Like")

        Button(action: {
            let wasBookmarked = viewModel.isBookmarked
            viewModel.toggleBookmark(for: quote)
            if wasBookmarked {
                onBookmarkRemoved?()
            }
        }) {
            actionIcon(viewModel.isBookmarked ? "bookmark.fill" : "bookmark", active: viewModel.isBookmarked)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(viewModel.isBookmarked ? "Remove from saved" : "Save")
    }
}
