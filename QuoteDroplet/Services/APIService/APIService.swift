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
    private let baseUrl = "https://quote-dropper-production.up.railway.app"
    
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
                if String(data: data, encoding: .utf8) != nil {
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
        var endpoint = "quotes/random"
        var queryParams: [String] = []
        
        if classification != "all" {
            queryParams.append("classification=\(classification)")
        }
        
        if isShortQuoteDesired {
            queryParams.append("maxLength=65")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        fetchData(endpoint: endpoint, responseType: Quote.self) { quote, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let quote = quote else {
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            print("✅ API Success: getRandomQuoteByClassification - Selected quote ID: \(quote.id)")
            completion(quote, nil)
        }
    }
    
    func getQuotesByAuthor(author: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        // Author is already URL encoded from the calling method
        let endpoint = "quotes?author=\(author)"
        
        print("🔍 Fetching quotes by author: \(author)")
        print("🔗 URL endpoint: \(endpoint)")
        
        fetchData(endpoint: endpoint, responseType: [Quote].self) { quotes, error in
            if let quotes = quotes {
                print("✅ Successfully fetched \(quotes.count) quotes for author: \(author)")
            } else if let error = error {
                print("❌ Error fetching quotes for author: \(error.localizedDescription)")
            }
            completion(quotes, error)
        }
    }
    
    func getQuotesBySearchKeyword(searchKeyword: String, searchCategory: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        guard let encodedKeyword = searchKeyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not encode search keyword"])
            completion(nil, error)
            return
        }
        
        var endpoint = "quotes?search=\(encodedKeyword)"
        if searchCategory != "all" {
            endpoint += "&category=\(searchCategory)"
        }
        fetchData(endpoint: endpoint, responseType: [Quote].self, completion: completion)
    }
    
    func getRecentQuotes(limit: Int, completion: @escaping ([Quote]?, Error?) -> Void) {
        let endpoint = "quotes/recent?limit=\(limit)"
        fetchData(endpoint: endpoint, responseType: [Quote].self, completion: completion)
    }
    
    func addQuote(text: String, author: String?, classification: String, submitterName: String?, completion: @escaping (Bool, Error?) -> Void) {
        var quoteObject: [String: Any] = [
            "text": text,
            "classification": classification
        ]
        
        if let author = author, !author.isEmpty {
            quoteObject["author"] = author
        }
        
        if let submitterName = submitterName, !submitterName.isEmpty {
            quoteObject["submitter_name"] = submitterName
        }
        
        print("📤 API: addQuote - Text: \(text), Author: \(author ?? "nil"), Classification: \(classification), Submitter: \(submitterName ?? "nil")")
        
        let endpoint = "quotes"
        
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
    
    func sendFeedback(text: String, type: String, email: String, completion: @escaping (Bool, Error?) -> Void) {
        var feedbackObject: [String: Any] = [
            "text": text,
            "type": type
        ]
        
        if !email.isEmpty {
            feedbackObject["email"] = email
        }
        
        print("📤 API: sendFeedback - Text: \(text), Type: \(type), Email: \(email)")
        
        let endpoint = "feedback"
        
        performRequest(endpoint: endpoint, method: .post, body: feedbackObject, responseType: EmptyResponse.self) { result in
            switch result {
            case .success:
                print("✅ API Success: sendFeedback - Feedback submitted successfully")
                completion(true, nil)
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
                case .decodingError:
                    // For sendFeedback, we don't really care about decoding errors since we expect no meaningful response
                    print("✅ API Success: sendFeedback - Feedback submitted successfully (ignoring decoding error)")
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
        let endpoint = "quotes/\(quoteID)/like"
        sendData(endpoint: endpoint, body: [:], responseType: Quote.self, completion: completion)
    }
    
    func unlikeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let endpoint = "quotes/\(quoteID)/like"
        // Use DELETE method for unlike
        performRequest(endpoint: endpoint, method: .delete, responseType: Quote.self) { result in
            switch result {
            case .success(let quote):
                completion(quote, nil)
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
    
    func likeQuoteAsync(quoteID: Int) async throws -> Quote? {
        let endpoint = "quotes/\(quoteID)/like"
        return try await withCheckedThrowingContinuation { continuation in
            sendData(endpoint: endpoint, body: [:], responseType: Quote.self) { quote, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: quote)
                }
            }
        }
    }
    
    func unlikeQuoteAsync(quoteID: Int) async throws -> Quote? {
        let endpoint = "quotes/\(quoteID)/like"
        return try await withCheckedThrowingContinuation { continuation in
            performRequest(endpoint: endpoint, method: .delete, responseType: Quote.self) { result in
                switch result {
                case .success(let quote):
                    continuation.resume(returning: quote)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getQuoteByID(id: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let endpoint = "quotes/\(id)"
        fetchData(endpoint: endpoint, responseType: Quote.self, completion: completion)
    }
    
    func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
        let endpoint = "quotes/count?category=\(category.rawValue.lowercased())"
        
        performRequest(endpoint: endpoint, method: .get, responseType: CountResponse.self) { result in
            switch result {
            case .success(let response):
                print("✅ API Success: getCountForCategory - Count: \(response.count) for category: \(category.rawValue)")
                DispatchQueue.main.async {
                    completion(response.count)
                }
            case .failure:
                print("⚠️ API Warning: getCountForCategory - Failed to get count, defaulting to 0")
                DispatchQueue.main.async {
                    completion(0)
                }
            }
        }
    }
    
    func getTopQuotes(category: QuoteCategory, completion: @escaping ([Quote]?, Error?) -> Void) {
        let categoryParam = category == .all ? "all" : category.rawValue.lowercased()
        let endpoint = "quotes/top?category=\(categoryParam)"
        
        fetchData(endpoint: endpoint, responseType: [Quote].self) { quotes, error in
            if let quotes = quotes {
                print("✅ API Success: getTopQuotes - Retrieved \(quotes.count) top quotes for category: \(category.rawValue)")
                completion(quotes, nil)
            } else {
                print("❌ API Error: getTopQuotes - Failed to get top quotes for category: \(category.rawValue)")
                completion(nil, error)
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
