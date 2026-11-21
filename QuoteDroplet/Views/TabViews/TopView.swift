//
//  TopView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 4/25/25.
//


import SwiftUI

@available(iOS 16.0, *)
struct TopView: View {
    @StateObject private var viewModel = TopViewModel(apiService: APIService(), localQuotesService: LocalQuotesService())
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @State private var copiedQuoteID: Int? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HeaderView(title: "Top Quotes", subtitle: "Most liked")
                CategoryChips(
                    categories: QuoteCategory.allCases.filter { $0 != .bookmarkedQuotes },
                    selection: $viewModel.selectedCategory
                )
                .onChange(of: viewModel.selectedCategory) { _ in
                    viewModel.loadTopQuotes()
                }
                leaderboardContent
            }
            .modifier(MainScreenBackgroundStyling())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                sharedVars.reloadFromDefaults()
                viewModel.loadLikedQuotes()
                viewModel.loadTopQuotes()
            }
        }
    }
}

@available(iOS 16.0, *)
extension TopView {
    private var palette: AppPalette { sharedVars.palette }

    private var leaderboardContent: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .tint(palette.accent)
                    .scaleEffect(1.3)
                    .padding(.top, 80)
            } else if viewModel.topQuotes.isEmpty {
                Text("No quotes available for this category")
                    .modifier(QuotesPageTextStyling())
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(Array(viewModel.topQuotes.enumerated()), id: \.element.id) { index, quote in
                        leaderboardQuoteRow(quote: quote, rank: index + 1)
                    }
                }
                .padding(.horizontal, AppMetrics.screenPadding)
                .padding(.top, 6)
                .padding(.bottom, 24)
            }
        }
    }

    private func rankBadge(_ rank: Int) -> some View {
        let isPodium = rank <= 3
        return Text("\(rank)")
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(isPodium ? palette.onAccent : palette.accent)
            .frame(width: 34, height: 34)
            .background(Circle().fill(isPodium ? palette.accent : palette.accent.opacity(0.14)))
    }
    
    private func leaderboardQuoteRow(quote: Quote, rank: Int) -> some View {
        HStack(alignment: .top, spacing: 14) {
            rankBadge(rank)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(quote.text)
                    .modifier(QuoteTextStyling(font: .system(.body, design: .serif)))
                
                HStack(alignment: .center) {
                    if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
                        AuthorLink(author: author, quote: quote)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            copyQuoteToClipboard(quote)
                        }) {
                            Image(systemName: copiedQuoteID == quote.id ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(copiedQuoteID == quote.id ? palette.accent : palette.secondaryText)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .accessibilityLabel("Copy")
                        
                        Button(action: {
                            viewModel.toggleLike(for: quote)
                        }) {
                            let liked = viewModel.isQuoteLiked(quote)
                            HStack(spacing: 4) {
                                Image(systemName: liked ? "heart.fill" : "heart")
                                    .font(.system(size: 16, weight: .medium))
                                Text("\(quote.likes ?? 0)")
                                    .font(.subheadline.weight(.semibold).monospacedDigit())
                            }
                            .foregroundColor(liked ? palette.accent : palette.secondaryText)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .accessibilityLabel("Like")
                    }
                }
            }
        }
        .modifier(CardStyling(padding: 16))
    }
    
    private func copyQuoteToClipboard(_ quote: Quote) {
        let quoteText = formatQuoteForClipboard(quote)
        UIPasteboard.general.string = quoteText
        
        // Haptic feedback plus a brief checkmark on the copy button
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.easeOut(duration: 0.15)) { copiedQuoteID = quote.id }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            if copiedQuoteID == quote.id {
                withAnimation(.easeOut(duration: 0.2)) { copiedQuoteID = nil }
            }
        }
    }
    
    private func formatQuoteForClipboard(_ quote: Quote) -> String {
        var formattedText = "\"\(quote.text)\""
        
        if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
            formattedText += " — \(author)"
        }
        
        return formattedText
    }
}

@available(iOS 16.0, *)
struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(SharedVarsBetweenTabs())
    }
}

// ViewModel for TopView
@available(iOS 15, *)
class TopViewModel: ObservableObject {
    @Published var topQuotes: [Quote] = []
    @Published var selectedCategory: QuoteCategory = .all
    @Published var isLoading: Bool = false
    @Published var likedQuoteIDs: Set<Int> = []
    @Published var isLiking: Bool = false
    
    private let apiService: IAPIService
    private let localQuotesService: ILocalQuotesService
    
    init(apiService: IAPIService, localQuotesService: ILocalQuotesService) {
        self.apiService = apiService
        self.localQuotesService = localQuotesService
        loadLikedQuotes()
    }
    
    func loadTopQuotes() {
        isLoading = true
        topQuotes = []
        
        apiService.getTopQuotes(category: selectedCategory) { [weak self] quotes, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let quotes = quotes {
                    self.topQuotes = quotes
                } else {
                    // Handle error
                    self.topQuotes = []
                }
            }
        }
    }
    
    func loadLikedQuotes() {
        let likedQuotes = localQuotesService.getLikedQuotes()
        likedQuoteIDs = Set(likedQuotes.map { $0.id })
    }
    
    func isQuoteLiked(_ quote: Quote) -> Bool {
        return likedQuoteIDs.contains(quote.id)
    }
    
    func toggleLike(for quote: Quote) {
        guard !isLiking else { return }
        
        // Read the liked state before changing it, so liking calls the like endpoint (and vice versa)
        let wasLiked = isQuoteLiked(quote)
        
        // Update local state
        if wasLiked {
            likedQuoteIDs.remove(quote.id)
        } else {
            likedQuoteIDs.insert(quote.id)
        }
        
        // Save to local storage
        localQuotesService.saveLikedQuote(quote: quote, isLiked: !wasLiked)
        
        isLiking = true
        let completion: (Quote?, Error?) -> Void = { [weak self] updatedQuote, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let updatedQuote = updatedQuote, let index = self.topQuotes.firstIndex(where: { $0.id == updatedQuote.id }) {
                    self.topQuotes[index] = updatedQuote
                }
                self.isLiking = false
            }
        }
        
        if wasLiked {
            apiService.unlikeQuote(quoteID: quote.id, completion: completion)
        } else {
            apiService.likeQuote(quoteID: quote.id, completion: completion)
        }
    }
} 
