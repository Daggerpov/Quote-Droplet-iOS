//
//  SearchView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-09-08.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct SearchView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel(
        localQuotesService: LocalQuotesService(),
        apiService: APIService()
    )

    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @FocusState private var isSearchFocused: Bool

    private let suggestions = ["Seneca", "courage", "Marcus Aurelius", "time", "kindness", "Maya Angelou"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HeaderView(title: "Search", subtitle: "Find a quote")
                searchField
                CategoryChips(categories: QuoteCategory.allCases, selection: $viewModel.activeCategory)
                    .onChange(of: viewModel.activeCategory) { _ in
                        viewModel.loadQuotesBySearch()
                    }
                ScrollView(.vertical) {
                    LazyVStack(spacing: 16) {
                        if viewModel.searchText != "" {
                            ForEach(viewModel.quotes) { quote in
                                SingleQuoteView(
                                    quote: quote,
                                    from: .standardView,
                                    searchText: viewModel.searchText
                                )
                            }
                        } else {
                            suggestionsView
                        }
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .modifier(MainScreenBackgroundStyling())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear() {
                sharedVars.reloadFromDefaults()
            }
        }
    }
}

@available(iOS 16.0, *)
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(SharedVarsBetweenTabs())
    }
}

@available(iOS 16.0, *)
extension SearchView {
    private var searchField: some View {
        let palette = sharedVars.palette
        return HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.semibold))
                .foregroundColor(palette.secondaryText)
            TextField("", text: $viewModel.searchText, prompt: Text("Quote text or author").foregroundColor(palette.secondaryText))
                .foregroundColor(palette.text)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.loadQuotesBySearch()
                }

            // Clear/dismiss button
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.clearSearch()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundColor(palette.secondaryText)
                }
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                .fill(palette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                .stroke(isSearchFocused ? palette.accent.opacity(0.7) : palette.hairline, lineWidth: isSearchFocused ? 1.5 : 1)
        )
        .padding(.horizontal, AppMetrics.screenPadding)
    }

    private var suggestionsView: some View {
        let palette = sharedVars.palette
        return VStack(alignment: .leading, spacing: 14) {
            SectionLabel(text: "Try searching for")
            FlowLayout(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        viewModel.searchText = suggestion
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkle.magnifyingglass")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(palette.accent)
                            Text(suggestion)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(palette.text)
                        }
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(Capsule().fill(palette.card))
                        .overlay(Capsule().stroke(palette.hairline, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            Text("Search matches words in a quote and in its author's name. Pick a category above to narrow it down.")
                .font(.footnote)
                .foregroundColor(palette.secondaryText)
                .padding(.horizontal, 4)
                .padding(.top, 6)
        }
        .padding(.horizontal, AppMetrics.screenPadding)
        .padding(.top, 8)
    }
}

/// Lays children out in rows, wrapping to the next row when one is full.
@available(iOS 16.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, widest: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            widest = max(widest, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: proposal.width ?? widest, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
