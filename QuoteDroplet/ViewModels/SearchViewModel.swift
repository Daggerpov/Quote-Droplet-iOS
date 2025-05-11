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
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService
    
    init(localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    public func loadQuotesBySearch() -> Void {
        guard !isLoadingMore else { return }
        
        self.quotes = []
        
        self.isLoadingMore = true
        let group: DispatchGroup = DispatchGroup()
        
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
            
            let quotesToAppend: [Quote] = Array(quotes.prefix(SearchViewModel.quotesPerPage))
            
            for quote in quotesToAppend {
                DispatchQueue.main.async {
                    if !self.quotes.contains(where: { $0.id == quote.id }) {
                        self.quotes.append(quote)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.isLoadingMore = false
                self.totalQuotesLoaded += quotesToAppend.count
            }
        }
    }
}
