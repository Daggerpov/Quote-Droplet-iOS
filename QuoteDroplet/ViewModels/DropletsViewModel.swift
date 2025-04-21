//
//  DropletsViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

@available(iOS 15, *)
class DropletsViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var savedQuotes: [Quote] = []
    @Published var recentQuotes: [Quote] = []
    @Published var selected: SelectedPage = .feed
    
    static let quotesPerPage = 5
    static let maxQuotes: Int = 15
    
    private var isLoadingMore: Bool = false
    private var totalQuotesLoaded: Int = 0
    private var totalSavedQuotesLoaded: Int = 0
    private var totalRecentQuotesLoaded: Int = 0
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService
    
    init(localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
    }
    
    func setSelected(newValue: SelectedPage) -> Void {
        self.selected = newValue
        // Check if we need to load quotes for the selected tab
        self.checkMoreQuotesNeeded()
    }
    
    func getTitleText() -> String {
        switch self.selected {
            case .feed: return "Quotes Feed"
            case .saved: return "Saved Quotes"
            case .recent: return "Recent Quotes"
        }
    }
    
    func getPageSpecificQuotes() -> [Quote] {
        switch self.selected {
            case .feed: return self.quotes
            case .saved: return self.savedQuotes
            case .recent: return self.recentQuotes
        }
    }
    
    func getPageSpecificEmptyText() -> String {
        switch self.selected {
            case .feed:
                return "Loading Quotes Feed..."
            case .saved:
                return "You have no saved quotes. \n\nPlease save some from the Quotes Feed by pressing this:"
            case .recent:
                return "You have no recent quotes. \n\nBe sure to enable notifications to see them listed here.\n\nQuotes shown from the app's widget will appear here soon. Stay tuned for that update."
        }
    }
    
    func loadInitialQuotes() -> Void {
        self.totalQuotesLoaded = 0
        self.totalSavedQuotesLoaded = 0
        self.totalRecentQuotesLoaded = 0
        self.loadMoreQuotes() // Initial load
    }
    
    public func checkMoreQuotesNeeded() -> Void {
        switch self.selected {
        case .feed:
            if !self.isLoadingMore && self.quotes.count < Self.maxQuotes {
                self.loadMoreQuotes()
            }
        case .saved:
            if !self.isLoadingMore && self.savedQuotes.count < Self.maxQuotes {
                self.loadMoreQuotes()
            }
        case .recent:
            if !self.isLoadingMore && self.recentQuotes.count < Self.maxQuotes {
                self.loadMoreQuotes()
            }
        }
    }
    
    public func checkLimitReached() -> Bool {
        return !self.isLoadingMore && (
            (self.selected == .feed && self.quotes.count >= Self.maxQuotes) || (self.selected == .saved && self.savedQuotes.count >= Self.maxQuotes) || (self.selected == .recent && self.recentQuotes.count >= Self.maxQuotes))
    }
    
    public func loadMoreQuotes() -> Void {
        guard !self.isLoadingMore else { return }
        
        self.isLoadingMore = true
        let group = DispatchGroup()
        
        if selected == .feed {
            for _ in 0..<Self.quotesPerPage {
                group.enter()
                apiService
                    .getRandomQuoteByClassification(
                        classification: "all",
                        completion: { [weak self] quote, error in
                            guard let self = self else { return }
                            if let quote = quote, !self.quotes.contains(where: { $0.id == quote.id }) {
                                DispatchQueue.main.async {
                                    self.quotes.append(quote)
                                }
                            }
                            group.leave()
                        },
                        isShortQuoteDesired: false
                    )
            }
        } else if selected == .saved {
            // Clear existing saved quotes before reloading
            DispatchQueue.main.async {
                self.savedQuotes = []
            }
            
            let bookmarkedQuotes: [Quote] = self.localQuotesService.getBookmarkedQuotes()
            print("DEBUG: Found \(bookmarkedQuotes.count) bookmarked quotes")
            
            var bookmarkedQuoteIDs: [Int] = []
            for bookmarkedQuote in bookmarkedQuotes {
                bookmarkedQuoteIDs.append(bookmarkedQuote.id)
            }
            print("DEBUG: Bookmarked quote IDs: \(bookmarkedQuoteIDs)")
            
            if bookmarkedQuoteIDs.isEmpty {
                // No need to make API calls if there are no IDs
                self.isLoadingMore = false
                return
            }
            
            for id in bookmarkedQuoteIDs {
                group.enter()
                apiService.getQuoteByID(id: id) { [weak self] quote, error in
                    guard let self = self else { return }
                    if let error = error {
                        print("DEBUG: Error fetching quote ID \(id): \(error)")
                    }
                    if let quote = quote {
                        print("DEBUG: Successfully fetched quote ID \(id)")
                        if !self.savedQuotes.contains(where: { $0.id == quote.id }) {
                            DispatchQueue.main.async {
                                self.savedQuotes.append(quote)
                                print("DEBUG: Added quote ID \(quote.id) to savedQuotes, count now: \(self.savedQuotes.count)")
                            }
                        } else {
                            print("DEBUG: Quote ID \(quote.id) already in savedQuotes")
                        }
                    } else {
                        print("DEBUG: No quote returned for ID \(id)")
                    }
                    group.leave()
                }
            }
        } else if selected == .recent {
            NotificationSchedulerService.shared.saveSentNotificationsAsRecents()
            let recentQuotes = self.localQuotesService.getRecentLocalQuotes()
            var recentQuoteIDs: [Int] = []
            for recentQuote in recentQuotes {
                recentQuoteIDs.append(recentQuote.id)
            }
            for id in recentQuoteIDs {
                group.enter()
                apiService.getQuoteByID(id: id) { [weak self] quote, error in
                    guard let self = self else { return }
                    if let quote = quote, !self.recentQuotes.contains(where: { $0.id == quote.id }) {
                        DispatchQueue.main.async {
                            self.recentQuotes.append(quote)
                        }
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoadingMore = false
            if self.selected == .feed {
                self.totalQuotesLoaded += Self.quotesPerPage
            } else if self.selected == .saved {
                self.totalSavedQuotesLoaded += Self.quotesPerPage
            }else if self.selected == .recent {
                self.totalRecentQuotesLoaded += Self.quotesPerPage
            }
        }
    }
}
