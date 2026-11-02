//
//  AuthorViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

class AuthorViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var isLoadingMore: Bool = false
    static let quotesPerPage: Int = 100
    private var totalQuotesLoaded: Int = 0
    static let maxQuotes: Int = 200
    
    let quote: Quote
    let apiService: IAPIService
    let localQuotesService: ILocalQuotesService
    
    init(quote: Quote, localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.quote = quote
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    public func loadInitialQuotes() -> Void {
        self.totalQuotesLoaded = 0
        self.loadMoreQuotes() // Initial load
    }
    
    public func loadMoreQuotes() -> Void {
        guard !self.isLoadingMore else { return }
        guard let author: String = self.quote.author else { return }
        
        self.isLoadingMore = true
        
        apiService.getQuotesByAuthor(author: author) { [weak self] quotes, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                defer { self.isLoadingMore = false }
                
                if let error = error {
                    print("Error fetching quotes: \(error)")
                    return
                }
                
                guard let quotes = quotes else {
                    print("No quotes found.")
                    return
                }
                
                let quotesToAppend: [Quote] = Array(quotes.prefix(AuthorViewModel.quotesPerPage))
                for quote in quotesToAppend where !self.quotes.contains(where: { $0.id == quote.id }) {
                    self.quotes.append(quote)
                }
                self.totalQuotesLoaded += AuthorViewModel.quotesPerPage
            }
        }
    }
}
