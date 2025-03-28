// Taken directly from Quote Droplet (MacOS XCode project)

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum RequestError: Error {
    case invalidURL
    case networkError(Error)
    case httpError(Int)
    case noData
    case decodingError(Error)
    case jsonParsingError(Error)
}

class APIService: IAPIService {
    private let baseUrl = "http://quote-dropper-production.up.railway.app"
    
    // MARK: - Generic Request Methods
    
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, RequestError>) -> Void
    ) {
        let urlString = "\(baseUrl)/\(endpoint)"
        print("🔍 API Request: \(method.rawValue) - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ API Error: Invalid URL: \(urlString)")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set additional headers if provided
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body for POST/PUT requests
        if let body = body, (method == .post || method == .put) {
            print("📤 API Request: Payload: \(body)")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                print("❌ API Error: JSON Serialization Error: \(error.localizedDescription)")
                completion(.failure(.jsonParsingError(error)))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                print("❌ API Error: Network Error: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            // Handle HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    print("❌ API Error: HTTP Error: \(httpResponse.statusCode)")
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
            } else {
                print("❌ API Error: Invalid Response")
                completion(.failure(.httpError(-1)))
                return
            }
            
            // Handle data
            guard let data = data else {
                print("❌ API Error: No Data Received")
                completion(.failure(.noData))
                return
            }
            
            print("📦 API Data: Received \(data.count) bytes")
            
            // Debug raw response if needed
            if responseType == [Quote].self || responseType == Quote.self {
                if let dataString = String(data: data, encoding: .utf8) {
                    if responseType == [Quote].self {
                        do {
                            let quotes = try JSONDecoder().decode([Quote].self, from: data)
                            print("📋 API Raw Response: Received \(quotes.count) quotes")
                        } catch {
                            print("📋 API Raw Response: Could not parse quote array")
                        }
                    } else {
                        print("📋 API Raw Response: Received a single quote")
                    }
                }
            }
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(T.self, from: data)
                print("✅ API Success: Decoded response of type \(T.self)")
                completion(.success(decodedResponse))
            } catch {
                print("❌ API Error: Decoding Error: \(error.localizedDescription)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // Helper for fetching data (GET requests)
    private func fetchData<T: Decodable>(
        endpoint: String,
        responseType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        performRequest(
            endpoint: endpoint,
            method: .get,
            responseType: responseType
        ) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                let nsError: NSError
                switch error {
                case .invalidURL:
                    nsError = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                case .networkError(let underlyingError):
                    nsError = underlyingError as NSError
                case .httpError(let statusCode):
                    nsError = NSError(domain: "HTTPError", code: statusCode, userInfo: nil)
                case .noData:
                    nsError = NSError(domain: "NoDataError", code: -1, userInfo: nil)
                case .decodingError(let underlyingError):
                    nsError = underlyingError as NSError
                case .jsonParsingError(let underlyingError):
                    nsError = underlyingError as NSError
                }
                completion(nil, nsError)
            }
        }
    }
    
    // Helper for sending data (POST requests)
    private func sendData<T: Decodable>(
        endpoint: String,
        body: [String: Any],
        responseType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        performRequest(
            endpoint: endpoint,
            method: .post,
            body: body,
            responseType: responseType
        ) { result in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                let nsError: NSError
                switch error {
                case .invalidURL:
                    nsError = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                case .networkError(let underlyingError):
                    nsError = underlyingError as NSError
                case .httpError(let statusCode):
                    if statusCode == 409 {
                        nsError = NSError(domain: "ConflictError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Thanks for submitting a quote.\n\nIt happens to already exist in the database, though. Great minds think alike."])
                    } else {
                        nsError = NSError(domain: "HTTPError", code: statusCode, userInfo: nil)
                    }
                case .noData:
                    nsError = NSError(domain: "NoDataError", code: -1, userInfo: nil)
                case .decodingError(let underlyingError):
                    nsError = underlyingError as NSError
                case .jsonParsingError(let underlyingError):
                    nsError = underlyingError as NSError
                }
                completion(nil, nsError)
            }
        }
    }
    
    // MARK: - API Methods
    
    func getRandomQuoteByClassification(classification: String, completion: @escaping (Quote?, Error?) -> Void, isShortQuoteDesired: Bool = false) {
        var endpoint: String
        if classification == "all" {
            endpoint = "quotes"
        } else {
            endpoint = "quotes/classification=\(classification)"
        }
        
        if isShortQuoteDesired {
            endpoint += "/maxQuoteLength=65"
        }
        
        fetchData(endpoint: endpoint, responseType: [Quote].self) { quotes, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let quotes = quotes else {
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            if quotes.isEmpty {
                print("⚠️ API Warning: getRandomQuoteByClassification - No quotes found")
                completion(Quote(id: -1, text: "No Quote Found.", author: nil, classification: nil, likes: 0), nil)
            } else {
                let randomIndex = Int.random(in: 0..<quotes.count)
                let selectedQuote = quotes[randomIndex]
                print("✅ API Success: getRandomQuoteByClassification - Selected quote ID: \(selectedQuote.id)")
                completion(selectedQuote, nil)
            }
        }
    }
    
    func getQuotesByAuthor(author: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let endpoint = "quotes/author=\(author)"
        fetchData(endpoint: endpoint, responseType: [Quote].self, completion: completion)
    }
    
    func getQuotesBySearchKeyword(searchKeyword: String, searchCategory: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let endpoint = "admin/search/\(searchKeyword)?category=\(searchCategory)"
        fetchData(endpoint: endpoint, responseType: [Quote].self, completion: completion)
    }
    
    func getRecentQuotes(limit: Int, completion: @escaping ([Quote]?, Error?) -> Void) {
        let endpoint = "quotes/recent/\(limit)"
        fetchData(endpoint: endpoint, responseType: [Quote].self, completion: completion)
    }
    
    func addQuote(text: String, author: String?, classification: String, completion: @escaping (Bool, Error?) -> Void) {
        let endpoint = "quotes"
        
        // Create the quote object to be sent in the request body
        let quoteObject: [String: Any] = [
            "text": text,
            "author": author ?? "", // If author is nil, send an empty string
            "classification": classification.lowercased(), // Convert classification to lowercase
            "approved": false, // Set approved status to false for new quotes
            "likes": 0
        ]
        
        // Special case: we don't expect a Quote in response but a success status
        performRequest(endpoint: endpoint, method: .post, body: quoteObject, responseType: EmptyResponse.self) { result in
            switch result {
            case .success:
                print("✅ API Success: addQuote - Quote added successfully")
                completion(true, nil)
            case .failure(let error):
                let nsError: NSError
                switch error {
                case .invalidURL:
                    nsError = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                case .networkError(let underlyingError):
                    nsError = underlyingError as NSError
                case .httpError(let statusCode):
                    if statusCode == 409 {
                        nsError = NSError(domain: "ConflictError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Thanks for submitting a quote.\n\nIt happens to already exist in the database, though. Great minds think alike."])
                    } else {
                        nsError = NSError(domain: "HTTPError", code: statusCode, userInfo: nil)
                    }
                case .noData:
                    nsError = NSError(domain: "NoDataError", code: -1, userInfo: nil)
                case .decodingError:
                    // For addQuote, we don't really care about decoding errors since we expect no meaningful response
                    print("✅ API Success: addQuote - Quote added successfully (ignoring decoding error)")
                    completion(true, nil)
                    return
                case .jsonParsingError(let underlyingError):
                    nsError = underlyingError as NSError
                }
                completion(false, nsError)
            }
        }
    }
    
    func likeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let endpoint = "quotes/like/\(quoteID)"
        sendData(endpoint: endpoint, body: [:], responseType: Quote.self, completion: completion)
    }
    
    func unlikeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let endpoint = "quotes/unlike/\(quoteID)"
        sendData(endpoint: endpoint, body: [:], responseType: Quote.self, completion: completion)
    }
    
    func getQuoteByID(id: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let endpoint = "quotes/\(id)"
        fetchData(endpoint: endpoint, responseType: Quote.self, completion: completion)
    }
    
    func getLikeCountForQuote(quoteGiven: Quote, completion: @escaping (Int) -> Void) {
        let endpoint = "quoteLikes/\(quoteGiven.id)"
        
        performRequest(endpoint: endpoint, method: .get, responseType: LikeCountResponse.self) { result in
            switch result {
            case .success(let response):
                print("✅ API Success: getLikeCountForQuote - Like count: \(response.likes)")
                completion(response.likes)
            case .failure:
                print("⚠️ API Warning: getLikeCountForQuote - Failed to get like count, defaulting to 0")
                completion(0)
            }
        }
    }
    
    func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
        let endpoint = "quoteCount?category=\(category.rawValue.lowercased())"
        
        performRequest(endpoint: endpoint, method: .get, responseType: CountResponse.self) { result in
            switch result {
            case .success(let response):
                print("✅ API Success: getCountForCategory - Count: \(response.count) for category: \(category.rawValue)")
                completion(response.count)
            case .failure:
                print("⚠️ API Warning: getCountForCategory - Failed to get count, defaulting to 0")
                completion(0)
            }
        }
    }
}

// MARK: - Helper Response Types

struct EmptyResponse: Decodable {}

struct LikeCountResponse: Decodable {
    let likes: Int
}

struct CountResponse: Decodable {
    let count: Int
}
