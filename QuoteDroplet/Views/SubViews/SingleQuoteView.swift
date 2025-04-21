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
    @ObservedObject var viewModel: SingleQuoteViewModel
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    var quote: Quote
    var from: SingleQuoteSource
    var searchText: String?
    
    init(quote: Quote, from: SingleQuoteSource, searchText: String? = "") {
        self.quote = quote
        self.from = from
        self.searchText = searchText
        self.viewModel = SingleQuoteViewModel(
            localQuotesService: LocalQuotesService(),
            apiService: APIService(), quote: quote, from: from)
    }
    
    var body: some View {
        VStack {
            quoteTextView
            authorTextView
            quoteInteractionButtons
        }
        .modifier(QuotesSectionOuterStyling())
        .padding(.horizontal)
        .onAppear {
            viewModel.getQuoteInfo()
        }
        
    }
}

@available(iOS 16.0, *)
extension SingleQuoteView {
    private var attributedString: AttributedString {
        var attributedString = AttributedString(quote.text)
        let searchTextLowercased = (searchText ?? "").lowercased()
        let textLowercased = quote.text.lowercased()
        var searchStartIndex = textLowercased.startIndex
        
        // Loop to find and highlight all occurrences
        while let range = textLowercased.range(of: searchTextLowercased, range: searchStartIndex..<textLowercased.endIndex) {
            // Convert String.Index to AttributedString.Index
            if let attributedRange = Range(NSRange(range, in: textLowercased), in: attributedString) {
                attributedString[attributedRange].backgroundColor = (colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .yellow).opacity(0.3)
            }
            // Move searchStartIndex to the end of the found range to continue searching
            searchStartIndex = range.upperBound
        }
        
        return attributedString
    }

    private var quoteTextView: some View {
        HStack {
            Text(attributedString)
                .font(.title3)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                .padding(.bottom, 2)
                .frame(alignment: .leading)
            Spacer()
        }
    }

    private var authorTextView: some View {
        HStack{
            if let author: String = quote.author, isAuthorValid(authorGiven: quote.author) {
                HStack {
                    Spacer()
                    Text("— \(author)")
                        .font(.body)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                        .padding(.bottom, 5)
                        .frame(alignment: .trailing)
                }
            }
        }
    }

    private var quoteInteractionButtons: some View {
        HStack {
            HStack {
                Button(action: {
                    viewModel.toggleLike(for: quote)
                    viewModel.likeQuoteAction(for: quote)
                }) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .modifier(QuoteInteractionButtonStyling())
                }

                // Display the like count next to the heart button
                Text("\(viewModel.likes)")
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
            }

            Button(action: {
                viewModel.toggleBookmark(for: quote)
            }) {
                Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                    .modifier(QuoteInteractionButtonStyling())
            }.padding(.leading, 5)

            let authorForSharing = (isAuthorValid(authorGiven: quote.author)) ? quote.author : ""
            let wholeAuthorText = (authorForSharing != "") ? "\n— \(authorForSharing ?? "Unknown Author")" : ""

            Button(action: {
                UIPasteboard.general.setValue("\(quote.text)\(wholeAuthorText)",
                                              forPasteboardType: UTType.plainText.identifier)
                viewModel.toggleCopy(for: quote)
            }) {
                Image(systemName: "doc.on.doc")
                    .modifier(QuoteInteractionButtonStyling())
            }.padding(.leading, 5)
            
            if let url = URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603") {
                ShareLink(item: url, message: Text("From the Quote Droplet app:\n\n\"\(quote.text)\"\(wholeAuthorText)")) {
                    Image(systemName: "square.and.arrow.up")
                        .modifier(QuoteInteractionButtonStyling())
                        .padding(.leading, 5)
                }
            }

            Spacer()

            if (viewModel.shouldShowArrow()) {
                NavigationLink(destination: AuthorView(quote: viewModel.quote)) {
                    Image(systemName: "arrow.turn.down.right")
                        .modifier(QuoteInteractionButtonStyling())
                }
            }

        }
    }
}
