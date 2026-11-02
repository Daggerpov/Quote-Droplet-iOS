//
//  SingleQuoteViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import SwiftUI
import Foundation
import StoreKit

@MainActor @available(iOS 16.0, *)
class SingleQuoteViewModel: ObservableObject {
    @Published var isCopied: Bool = false
    @Published var isLiked: Bool = false
    @Published var isBookmarked: Bool = false
    @Published var likes: Int
    @Published var isLiking: Bool = false
    
    // MARK: app review vars
    //------------------------------------------------------------------------------------
    @AppStorage("interactions", store: UserDefaults(suiteName: "group.selectedSettings"))
    var interactions: Int = 0
    
    @Environment(\.requestReview) var requestReview: RequestReviewAction
    //------------------------------------------------------------------------------------
    
    var quote: Quote
    var from: SingleQuoteSource
    var searchText: String?
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService
    
    init(
        localQuotesService: ILocalQuotesService,
        apiService: IAPIService,
        quote: Quote,
        from: SingleQuoteSource = .standardView,
        searchText: String = ""
    ) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        self.quote = quote
        self.from = from
        self.searchText = searchText
        self.likes = quote.likes ?? 0
    }
    
    public func shouldShowArrow() -> Bool {
        return isAuthorValid(authorGiven: quote.author) && from != .authorView
    }
    
    public func getQuoteInfo() -> Void {
        isBookmarked = localQuotesService.isQuoteBookmarked(quote)
        isLiked = localQuotesService.isQuoteLiked(quote)
    }
    
    func increaseInteractions() -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.interactions += 1
            if (self.interactions == 21) {
                // within app, so review should show
                self.requestReview()
            }
        }
    }
    
    func toggleCopy(for quote: Quote) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isCopied.toggle()
            self.increaseInteractions()
        }
    }
    
    func toggleBookmark(for quote: Quote) -> Void {
        DispatchQueue.main.async { [weak self] in // weak self to avoid memory leaks
            guard let self = self else { return }
            self.isBookmarked.toggle()
            
            // Persist both directions, so unbookmarked quotes are removed from the Saved tab
            self.localQuotesService.saveBookmarkedQuote(quote: quote, isBookmarked: self.isBookmarked)
            
            self.increaseInteractions()
        }
    }
    
    func toggleLike(for quote: Quote) -> Void {
        guard !isLiking else { return }
        
        // Read the stored state before changing it, so the API call always matches what the user sees
        let wasLiked: Bool = localQuotesService.isQuoteLiked(quote)
        
        isLiked = !wasLiked
        localQuotesService.saveLikedQuote(quote: quote, isLiked: isLiked)
        // Optimistically update the count; the API response below replaces it with the real value
        likes = max(0, likes + (isLiked ? 1 : -1))
        isLiking = true
        increaseInteractions()
        
        let completion: (Quote?, Error?) -> Void = { [weak self] updatedQuote, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let updatedLikes = updatedQuote?.likes {
                    self.likes = updatedLikes
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
