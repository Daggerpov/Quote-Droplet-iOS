//
//  DropletsViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation
import WidgetKit

@available(iOS 15, *)
class DropletsViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var savedQuotes: [Quote] = []
    @Published var customQuotes: [Quote] = []
    @Published var selected: SelectedPage = .feed
    
    static let quotesPerPage = 5
    static let maxQuotes: Int = 15
    
    private var isLoadingMore: Bool = false
    private var totalQuotesLoaded: Int = 0
    private var totalSavedQuotesLoaded: Int = 0
    
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
            case .custom: return "Custom Quotes"
        }
    }
    
    func getPageSpecificQuotes() -> [Quote] {
        switch self.selected {
            case .feed: return self.quotes
            case .saved: return self.savedQuotes
            case .custom: return self.customQuotes
        }
    }
    
    func getPageSpecificEmptyText() -> String {
        switch self.selected {
            case .feed:
                return "Loading Quotes Feed..."
            case .saved:
                return "You have no saved quotes. \n\nPlease save some from the Quotes Feed by pressing this:"
            case .custom:
                return "You haven't added any quotes of your own yet."
        }
    }
    
    func removeSavedQuote(_ quote: Quote) -> Void {
        self.savedQuotes.removeAll { $0.id == quote.id }
    }

    // MARK: - Custom quotes

    /// Newest first, so a quote you just added shows at the top.
    func reloadCustomQuotes() -> Void {
        self.customQuotes = self.localQuotesService.getCustomQuotes().reversed()
    }

    /// Adds a quote (when `editing` is nil) or saves changes to an existing one. Returns false for empty text.
    @discardableResult
    func saveCustomQuote(text: String, author: String, editing: Quote? = nil) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return false }
        let authorValue: String? = trimmedAuthor.isEmpty ? nil : trimmedAuthor
        let quote: Quote
        if let editing = editing {
            quote = Quote(id: editing.id, text: trimmedText, author: authorValue,
                          classification: Quote.customClassification, likes: nil)
        } else {
            quote = Quote.newCustom(text: trimmedText, author: authorValue)
        }
        self.localQuotesService.saveCustomQuote(quote)
        self.reloadCustomQuotes()
        Self.customQuotesChanged()
        return true
    }

    func deleteCustomQuote(_ quote: Quote) -> Void {
        self.localQuotesService.deleteCustomQuote(quote)
        self.reloadCustomQuotes()
        Self.customQuotesChanged()
    }

    /// The widget and scheduled notifications draw from custom quotes when that category is picked.
    private static func customQuotesChanged() {
        guard NotificationSchedulerService.storedQuoteCategory == .custom else { return }
        NotificationSchedulerService.shared.scheduleNotifications()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func loadInitialQuotes() -> Void {
        self.totalQuotesLoaded = 0
        self.totalSavedQuotesLoaded = 0
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
        case .custom:
            self.reloadCustomQuotes()
        }
    }
    
    public func checkLimitReached() -> Bool {
        return !self.isLoadingMore && (
            (self.selected == .feed && self.quotes.count >= Self.maxQuotes) || (self.selected == .saved && self.savedQuotes.count >= Self.maxQuotes))
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
        } else if selected == .custom {
            self.reloadCustomQuotes()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoadingMore = false
            if self.selected == .feed {
                self.totalQuotesLoaded += Self.quotesPerPage
            } else if self.selected == .saved {
                self.totalSavedQuotesLoaded += Self.quotesPerPage
            }
        }
    }
}
