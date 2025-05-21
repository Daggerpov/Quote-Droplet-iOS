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
    @Published var authorImageURL: String? = nil
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
    
    func loadRemoteJSON<T: Decodable>(_ urlString: String, completion: @escaping  ((T) -> Void)) -> Void {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let request: URLRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                print("data loaded from loadRemoteJSON")
                
                if let imageResponse = decodedData as? GoogleImageSearchResponse,
                   let firstItem = imageResponse.items?.first {
                    DispatchQueue.main.async {
                        self?.authorImageURL = firstItem.link
                    }
                }
                
                completion(decodedData)
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    public func loadInitialQuotes() -> Void {
        self.totalQuotesLoaded = 0
        self.quotes = []
        self.loadMoreQuotes() // Initial load
    }
    
    public func loadMoreQuotes() -> Void {
        guard !self.isLoadingMore else { return }
        
        self.isLoadingMore = true
        
        guard let author: String = self.quote.author else { 
            self.isLoadingMore = false
            return 
        }
        
        apiService.getQuotesByAuthor(author: author) { [weak self] quotes, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching quotes: \(error)")
                    self.isLoadingMore = false
                    return
                }
                
                guard let quotes = quotes else {
                    print("No quotes found.")
                    self.isLoadingMore = false
                    return
                }
                
                let quotesToAppend: [Quote] = Array(quotes.prefix(AuthorViewModel.quotesPerPage))
                
                // Add all quotes that aren't already in the array
                for quote in quotesToAppend {
                    if !self.quotes.contains(where: { $0.id == quote.id }) {
                        self.quotes.append(quote)
                    }
                }
                
                self.isLoadingMore = false
                self.totalQuotesLoaded += AuthorViewModel.quotesPerPage
            }
        }
    }
    
    // Helper function to load author image using Google Custom Search
    func loadAuthorImage(authorName: String) {
        guard let APIKey: String = ProcessInfo.processInfo.environment["GoogleImagesAPIKey"] else {
            return
        }
        
        let formattedName = authorName.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://www.googleapis.com/customsearch/v1?key=\(APIKey)&cx=238ad9d0296fb425a&searchType=image&q=\(formattedName)"
        
        loadRemoteJSON(urlString) { [weak self] (data: GoogleImageSearchResponse) in
            // URL will be handled in loadRemoteJSON
        }
    }
}

