// Taken directly from Quote Droplet (MacOS XCode project)

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class APIService: IAPIService {
    private let baseUrl = "http://quote-dropper-production.up.railway.app"
    
    // MARK: - Generic API Methods
    
    private func fetchData<T: Decodable>(endpoint: String, method: HTTPMethod = .get, body: Data? = nil, queryParams: [String: String]? = nil, completion: @escaping (T?, Error?) -> Void) {
        var urlComponents = URLComponents(string: "\(baseUrl)/\(endpoint)")
        
        // Add query parameters if provided
        if let queryParams = queryParams, !queryParams.isEmpty {
            urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents?.url else {
            completion(nil, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method != .get {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                if let httpResponse = response as? HTTPURLResponse {
                    completion(nil, NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
                } else {
                    completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                }
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    private func sendData<T: Decodable, U: Encodable>(endpoint: String, body: U, method: HTTPMethod = .post, completion: @escaping (T?, Error?) -> Void) {
        do {
            let jsonData = try JSONEncoder().encode(body)
            fetchData(endpoint: endpoint, method: method, body: jsonData, completion: completion)
        } catch {
            completion(nil, error)
        }
    }
    
    private func sendRawData<T: Decodable>(endpoint: String, body: [String: Any], method: HTTPMethod = .post, completion: @escaping (T?, Error?) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            fetchData(endpoint: endpoint, method: method, body: jsonData, completion: completion)
        } catch {
            completion(nil, error)
        }
    }
    
    // MARK: - IAPIService Implementation
    
    func getRandomQuoteByClassification(classification: String, completion: @escaping (Quote?, Error?) -> Void, isShortQuoteDesired: Bool = false) {
        var endpoint = "quotes"
        var queryParams: [String: String] = [:]
        
        if classification != "all" {
            endpoint = "quotes"
            queryParams["classification"] = classification.lowercased()
        }
        
        if isShortQuoteDesired {
            queryParams["maxQuoteLength"] = "65"
        }
        
        fetchData(endpoint: endpoint, queryParams: queryParams) { (quotes: [Quote]?, error: Error?) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let quotes = quotes, !quotes.isEmpty else {
                completion(Quote(id: -1, text: "No Quote Found.", author: nil, classification: nil, likes: 0), nil)
                return
            }
            
            let randomIndex = Int.random(in: 0..<quotes.count)
            completion(quotes[randomIndex], nil)
        }
    }
    
    func getQuotesByAuthor(author: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        fetchData(endpoint: "quotes", queryParams: ["author": author], completion: completion)
    }
    
    func getQuotesBySearchKeyword(searchKeyword: String, searchCategory: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        fetchData(endpoint: "admin/search/\(searchKeyword)", queryParams: ["category": searchCategory], completion: completion)
    }
    
    func getRecentQuotes(limit: Int, completion: @escaping ([Quote]?, Error?) -> Void) {
        fetchData(endpoint: "quotes/recent/\(limit)", completion: completion)
    }
    
    func addQuote(text: String, author: String?, classification: String, completion: @escaping (Bool, Error?) -> Void) {
        let quoteObject: [String: Any] = [
            "text": text,
            "author": author ?? "",
            "classification": classification.lowercased(),
            "approved": false,
            "likes": 0
        ]
        
        struct EmptyResponse: Decodable {}
        
        sendRawData(endpoint: "quotes", body: quoteObject) { (response: EmptyResponse?, error: Error?) in
            if let error = error {
                // Handle 409 Conflict error specifically
                if let nsError = error as NSError?, nsError.domain == "HTTPError", nsError.code == 409 {
                    let conflictError = NSError(domain: "ConflictError", code: 409, userInfo: [NSLocalizedDescriptionKey: "Thanks for submitting a quote.\n\nIt happens to already exist in the database, though. Great minds think alike."])
                    completion(false, conflictError)
                    return
                }
                completion(false, error)
                return
            }
            
            completion(true, nil)
        }
    }
    
    func likeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        fetchData(endpoint: "quotes/like/\(quoteID)", method: .post, completion: completion)
    }
    
    func unlikeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        fetchData(endpoint: "quotes/unlike/\(quoteID)", method: .post, completion: completion)
    }
    
    func getQuoteByID(id: Int, completion: @escaping (Quote?, Error?) -> Void) {
        fetchData(endpoint: "quotes/\(id)", completion: completion)
    }
    
    func getLikeCountForQuote(quoteGiven: Quote, completion: @escaping (Int) -> Void) {
        struct LikeResponse: Decodable {
            let likes: Int
        }
        
        fetchData(endpoint: "quoteLikes/\(quoteGiven.id)") { (response: LikeResponse?, error: Error?) in
            if let response = response {
                completion(response.likes)
            } else {
                completion(0)
            }
        }
    }
    
    func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
        struct CountResponse: Decodable {
            let count: Int
        }
        
        fetchData(endpoint: "quoteCount", queryParams: ["category": category.rawValue.lowercased()]) { (response: CountResponse?, error: Error?) in
            if let response = response {
                completion(response.count)
            } else {
                completion(0)
            }
        }
    }
}
