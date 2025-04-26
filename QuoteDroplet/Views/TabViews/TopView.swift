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
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                VStack {
                    categoryFilterSection
                    leaderboardContent
                }
                .padding()
            }
            .modifier(MainScreenBackgroundStyling())
            .onAppear {
                viewModel.loadLikedQuotes()
                viewModel.loadTopQuotes()
            }
        }
    }
}

@available(iOS 16.0, *)
extension TopView {
    private var categoryFilterSection: some View {
        HStack {
            Text("Category:")
                .modifier(BasePicker_TextStyling())
            Picker("", selection: $viewModel.selectedCategory) {
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    Text(category.displayName)
                        .font(.headline)
                }
            }
            .modifier(BasePicker_PickerStyling())
            .onChange(of: viewModel.selectedCategory) { _ in
                viewModel.loadTopQuotes()
            }
        }
        .modifier(BasePicker_OuterBackgroundStyling())
        .padding(.vertical)
    }
    
    private var leaderboardContent: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.top, 50)
            } else if viewModel.topQuotes.isEmpty {
                VStack {
                    Spacer()
                    Text("No quotes available for this category")
                        .modifier(QuotesPageTextStyling())
                    Spacer()
                }
                .frame(height: 400)
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(viewModel.topQuotes.enumerated()), id: \.element.id) { index, quote in
                        leaderboardQuoteRow(quote: quote, rank: index + 1)
                    }
                }
            }
        }
    }
    
    private func leaderboardQuoteRow(quote: Quote, rank: Int) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("#\(rank)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                    .frame(width: 40, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(quote.text)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
                            Text("— \(author)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleLike(for: quote)
                            viewModel.likeQuoteAction(for: quote)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isQuoteLiked(quote) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                Text("\(quote.likes ?? 0)")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                    }
                }
            }
            
            Divider()
                .background(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .gray.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
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
        let isLiked = isQuoteLiked(quote)
        
        // Update local state
        if isLiked {
            likedQuoteIDs.remove(quote.id)
        } else {
            likedQuoteIDs.insert(quote.id)
        }
        
        // Save to local storage
        localQuotesService.saveLikedQuote(quote: quote, isLiked: !isLiked)
    }
    
    func likeQuoteAction(for quote: Quote) {
        guard !isLiking else { return }
        isLiking = true
        
        if isQuoteLiked(quote) {
            apiService.unlikeQuote(quoteID: quote.id) { [weak self] updatedQuote, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote, let index = self.topQuotes.firstIndex(where: { $0.id == updatedQuote.id }) {
                        self.topQuotes[index].likes = updatedQuote.likes
                    }
                    self.isLiking = false
                }
            }
        } else {
            apiService.likeQuote(quoteID: quote.id) { [weak self] updatedQuote, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let updatedQuote = updatedQuote, let index = self.topQuotes.firstIndex(where: { $0.id == updatedQuote.id }) {
                        self.topQuotes[index].likes = updatedQuote.likes
                    }
                    self.isLiking = false
                }
            }
        }
    }
} 
