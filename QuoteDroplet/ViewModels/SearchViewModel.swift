//
//  SearchViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var searchText: String = ""
    @Published var activeCategory: QuoteCategory = .all
    
    static let quotesPerPage: Int = 5
    
    private var isLoadingMore: Bool = false
    private let maxQuotes: Int = 10
    private var totalQuotesLoaded: Int = 0
    private var allSearchResults: [Quote] = [] // Store all results from API for client-side filtering
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService
    
    init(localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    // MARK: - Clear Search
    public func clearSearch() {
        searchText = ""
        quotes = []
        allSearchResults = []
    }
    
    // MARK: - Client-side filtering for author and text
    private var filteredQuotes: [Quote] {
        guard !searchText.isEmpty else { return [] }
        
        return allSearchResults.filter { quote in
            let searchLower = searchText.lowercased()
            let textMatches = quote.text.lowercased().contains(searchLower)
            let authorMatches = quote.author?.lowercased().contains(searchLower) ?? false
            return textMatches || authorMatches
        }
    }
    
    public func loadQuotesBySearch() -> Void {
        guard !isLoadingMore else { return }
        
        self.quotes = []
        self.allSearchResults = []
        
        self.isLoadingMore = true
        
        // Don't make an API call if search text is empty
        if searchText.isEmpty {
            self.isLoadingMore = false
            return
        }
        
        print("🔍 Search: Searching for \"\(searchText)\" in category \"\(activeCategory.rawValue)\"")
        
        apiService.getQuotesBySearchKeyword(searchKeyword: searchText, searchCategory: activeCategory.rawValue.lowercased()) { [weak self] quotes, error in
            guard let self = self else { return }
            if let error: Error = error {
                print("❌ Search Error: \(error.localizedDescription)")
                
                // Check for specific error types
                let nsError = error as NSError
                if nsError.domain == "NSURLErrorDomain" {
                    print("❌ Network Error: \(nsError.code) - This could be due to HTTP/HTTPS connectivity issues")
                } else if nsError.domain == "HTTPError" {
                    print("❌ HTTP Error: \(nsError.code) - The server rejected the request")
                } else if nsError.domain == "InvalidURL" {
                    print("❌ URL Error: The search URL may be invalid")
                }
                
                DispatchQueue.main.async {
                    self.isLoadingMore = false
                }
                return
            }
            
            guard let quotes: [Quote] = quotes else {
                print("⚠️ Search Warning: No quotes found for \"\(self.searchText)\"")
                DispatchQueue.main.async {
                    self.isLoadingMore = false
                }
                return
            }
            
            print("✅ Search Success: Found \(quotes.count) quotes matching \"\(self.searchText)\"")
            
            DispatchQueue.main.async {
                // Store all results for client-side filtering
                self.allSearchResults = quotes
                
                // Apply client-side filtering for both text and author
                let filteredResults = self.filteredQuotes
                let quotesToAppend: [Quote] = Array(filteredResults.prefix(SearchViewModel.quotesPerPage))
                
                for quote in quotesToAppend {
                    if !self.quotes.contains(where: { $0.id == quote.id }) {
                        self.quotes.append(quote)
                    }
                }
                
                self.isLoadingMore = false
                self.totalQuotesLoaded += quotesToAppend.count
                
                print("🎯 Filtered Results: Showing \(quotesToAppend.count) quotes after author/text filtering")
            }
        }
    }
}
