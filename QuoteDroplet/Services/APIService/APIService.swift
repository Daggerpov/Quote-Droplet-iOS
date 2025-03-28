// Taken directly from Quote Droplet (MacOS XCode project)

import Foundation


class APIService: IAPIService {
    private let baseUrl = "http://quote-dropper-production.up.railway.app"
    
    func getRandomQuoteByClassification(classification: String, completion: @escaping (Quote?, Error?) -> Void, isShortQuoteDesired: Bool = false) {
        var urlString: String;
        if classification == "all" {
            // Modify the URL to include a filter for approved quotes
            urlString = "\(baseUrl)/quotes"
        } else {
            // Modify the URL to include a filter for approved quotes and classification
            urlString = "\(baseUrl)/quotes/classification=\(classification)"
        }
        
        if isShortQuoteDesired {
            urlString += "/maxQuoteLength=65"
        }
        
        print("🔍 API Request: getRandomQuoteByClassification - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: getRandomQuoteByClassification - Invalid URL: \(urlString)")
            completion(nil, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: getRandomQuoteByClassification - Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: getRandomQuoteByClassification - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    print("❌ API Error: getRandomQuoteByClassification - HTTP Error: \(httpResponse.statusCode)")
                    completion(nil, error)
                    return
                }
            } else {
                print("❌ API Error: getRandomQuoteByClassification - Invalid Response")
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("❌ API Error: getRandomQuoteByClassification - No Data Received")
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            print("📦 API Data: getRandomQuoteByClassification - Received \(data.count) bytes")
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("📋 API Raw Response: \(dataString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let quotes = try decoder.decode([Quote].self, from: data)
                
                print("✅ API Success: getRandomQuoteByClassification - Decoded \(quotes.count) quotes")
                
                if quotes.isEmpty {
                    print("⚠️ API Warning: getRandomQuoteByClassification - No quotes found")
                    completion(Quote(id: -1, text: "No Quote Found.", author: nil, classification: nil, likes: 0), nil)
                } else {
                    let randomIndex = Int.random(in: 0..<quotes.count)
                    let selectedQuote = quotes[randomIndex]
                    print("✅ API Success: getRandomQuoteByClassification - Selected quote ID: \(selectedQuote.id)")
                    completion(selectedQuote, nil)
                }
            } catch {
                print("❌ API Error: getRandomQuoteByClassification - Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getQuotesByAuthor(author: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/author=\(author)"
        
        print("🔍 API Request: getQuotesByAuthor - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: getQuotesByAuthor - Invalid URL: \(urlString)")
            completion(nil, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: getQuotesByAuthor - Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: getQuotesByAuthor - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    print("❌ API Error: getQuotesByAuthor - HTTP Error: \(httpResponse.statusCode)")
                    completion(nil, error)
                    return
                }
            } else {
                print("❌ API Error: getQuotesByAuthor - Invalid Response")
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("❌ API Error: getQuotesByAuthor - No Data Received")
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            print("📦 API Data: getQuotesByAuthor - Received \(data.count) bytes")
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let quotes = try decoder.decode([Quote].self, from: data)
                print("✅ API Success: getQuotesByAuthor - Decoded \(quotes.count) quotes")
                completion(quotes, nil)
            } catch {
                print("❌ API Error: getQuotesByAuthor - Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getQuotesBySearchKeyword(searchKeyword: String, searchCategory: String, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/admin/search/\(searchKeyword)?category=\(searchCategory)"
        print("🔍 API Request: getQuotesBySearchKeyword - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: getQuotesBySearchKeyword - Invalid URL: \(urlString)")
            completion(nil, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: getQuotesBySearchKeyword - Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: getQuotesBySearchKeyword - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    print("❌ API Error: getQuotesBySearchKeyword - HTTP Error: \(httpResponse.statusCode)")
                    completion(nil, error)
                    return
                }
            } else {
                print("❌ API Error: getQuotesBySearchKeyword - Invalid Response")
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("❌ API Error: getQuotesBySearchKeyword - No Data Received")
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            print("📦 API Data: getQuotesBySearchKeyword - Received \(data.count) bytes")
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let quotes = try decoder.decode([Quote].self, from: data)
                print("✅ API Success: getQuotesBySearchKeyword - Decoded \(quotes.count) quotes")
                completion(quotes, nil)
            } catch {
                print("❌ API Error: getQuotesBySearchKeyword - Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getRecentQuotes(limit: Int, completion: @escaping ([Quote]?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/recent/\(limit)"
        print("🔍 API Request: getRecentQuotes - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: getRecentQuotes - Invalid URL: \(urlString)")
            completion(nil, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: getRecentQuotes - Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: getRecentQuotes - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    print("❌ API Error: getRecentQuotes - HTTP Error: \(httpResponse.statusCode)")
                    completion(nil, error)
                    return
                }
            } else {
                print("❌ API Error: getRecentQuotes - Invalid Response")
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("❌ API Error: getRecentQuotes - No Data Received")
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            print("📦 API Data: getRecentQuotes - Received \(data.count) bytes")
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let quotes = try decoder.decode([Quote].self, from: data)
                print("✅ API Success: getRecentQuotes - Decoded \(quotes.count) quotes")
                completion(quotes, nil)
            } catch {
                print("❌ API Error: getRecentQuotes - Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    
    func addQuote(text: String, author: String?, classification: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes"
        print("🔍 API Request: addQuote - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: addQuote - Invalid URL: \(urlString)")
            completion(false, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the quote object to be sent in the request body
        let quoteObject: [String: Any] = [
            "text": text,
            "author": author ?? "", // If author is nil, send an empty string
            "classification": classification.lowercased(), // Convert classification to lowercase
            "approved": false, // Set approved status to false for new quotes
            "likes": 0
        ]
        
        print("📤 API Request: addQuote - Payload: \(quoteObject)")
        
        // Convert the quote object to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: quoteObject, options: [])
            request.httpBody = jsonData
        } catch {
            print("❌ API Error: addQuote - JSON Serialization Error: \(error.localizedDescription)")
            completion(false, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: addQuote - Network Error: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: addQuote - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    if httpResponse.statusCode == 409 {
                        // Handle the 409 error here
                        let conflictError = NSError(domain: "ConflictError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Thanks for submitting a quote.\n\nIt happens to already exist in the database, though. Great minds think alike."])
                        print("⚠️ API Warning: addQuote - Conflict (409): Quote already exists")
                        completion(false, conflictError)
                    } else {
                        let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                        print("❌ API Error: addQuote - HTTP Error: \(httpResponse.statusCode)")
                        completion(false, error)
                    }
                    return
                }
            } else {
                print("❌ API Error: addQuote - Invalid Response")
                completion(false, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            // The quote was successfully added
            print("✅ API Success: addQuote - Quote added successfully")
            completion(true, nil)
        }.resume()
    }
    
    func likeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/like/\(quoteID)"
        print("🔍 API Request: likeQuote - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: likeQuote - Invalid URL: \(urlString)")
            completion(nil, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: likeQuote - Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: likeQuote - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    print("❌ API Error: likeQuote - HTTP Error: \(httpResponse.statusCode)")
                    completion(nil, error)
                    return
                }
            } else {
                print("❌ API Error: likeQuote - Invalid Response")
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("❌ API Error: likeQuote - No Data Received")
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            print("📦 API Data: likeQuote - Received \(data.count) bytes")
            
            // Parse the JSON response to get the updated quote
            do {
                let updatedQuote = try JSONDecoder().decode(Quote.self, from: data)
                print("✅ API Success: likeQuote - Quote ID: \(updatedQuote.id), Likes: \(updatedQuote.likes ?? 0)")
                completion(updatedQuote, nil)
            } catch {
                print("❌ API Error: likeQuote - Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func unlikeQuote(quoteID: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/unlike/\(quoteID)"
        print("🔍 API Request: unlikeQuote - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: unlikeQuote - Invalid URL: \(urlString)")
            completion(nil, error)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: unlikeQuote - Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: unlikeQuote - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    print("❌ API Error: unlikeQuote - HTTP Error: \(httpResponse.statusCode)")
                    completion(nil, error)
                    return
                }
            } else {
                print("❌ API Error: unlikeQuote - Invalid Response")
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("❌ API Error: unlikeQuote - No Data Received")
                completion(nil, NSError(domain: "NoDataError", code: -1, userInfo: nil))
                return
            }
            
            print("📦 API Data: unlikeQuote - Received \(data.count) bytes")
            
            // Parse the JSON response to get the updated quote
            do {
                let updatedQuote = try JSONDecoder().decode(Quote.self, from: data)
                print("✅ API Success: unlikeQuote - Quote ID: \(updatedQuote.id), Likes: \(updatedQuote.likes ?? 0)")
                completion(updatedQuote, nil)
            } catch {
                print("❌ API Error: unlikeQuote - Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getQuoteByID(id: Int, completion: @escaping (Quote?, Error?) -> Void) {
        let urlString = "\(baseUrl)/quotes/\(id)"
        print("🔍 API Request: getQuoteByID - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ API Error: getQuoteByID - Invalid URL: \(urlString)")
            completion(nil, error)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ API Error: getQuoteByID - Network Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: getQuoteByID - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    print("❌ API Error: getQuoteByID - HTTP Error: \(httpResponse.statusCode)")
                    completion(nil, error)
                    return
                }
            } else {
                print("❌ API Error: getQuoteByID - Invalid Response")
                completion(nil, NSError(domain: "HTTPError", code: -1, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("❌ API Error: getQuoteByID - No Data Received")
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            print("📦 API Data: getQuoteByID - Received \(data.count) bytes")
            
            do {
                let quote = try JSONDecoder().decode(Quote.self, from: data)
                print("✅ API Success: getQuoteByID - Retrieved quote ID: \(quote.id)")
                completion(quote, nil)
            } catch {
                print("❌ API Error: getQuoteByID - Decoding Error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
    func getLikeCountForQuote(quoteGiven: Quote, completion: @escaping (Int) -> Void) {
        let urlString = "\(baseUrl)/quoteLikes/\(quoteGiven.id)"
        print("🔍 API Request: getLikeCountForQuote - URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ API Error: getLikeCountForQuote - Invalid URL: \(urlString)")
            completion(0)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ API Error: getLikeCountForQuote - Network Error: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: getLikeCountForQuote - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    print("❌ API Error: getLikeCountForQuote - HTTP Error: \(httpResponse.statusCode)")
                    completion(0)
                    return
                }
            } else {
                print("❌ API Error: getLikeCountForQuote - Invalid Response")
                completion(0)
                return
            }
            
            guard let data = data else {
                print("❌ API Error: getLikeCountForQuote - No Data Received")
                completion(0)
                return
            }
            
            print("📦 API Data: getLikeCountForQuote - Received \(data.count) bytes")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let likeCount = json["likes"] as? Int {
                    print("✅ API Success: getLikeCountForQuote - Like count: \(likeCount)")
                    completion(likeCount)
                } else {
                    print("⚠️ API Warning: getLikeCountForQuote - Could not find likes count in response")
                    completion(0)
                }
            } catch {
                print("❌ API Error: getLikeCountForQuote - JSON Parsing Error: \(error.localizedDescription)")
                completion(0)
            }
        }.resume()
    }
    
    func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
        let urlString = "\(baseUrl)/quoteCount?category=\(category.rawValue.lowercased())"
        print("🔍 API Request: getCountForCategory - URL: \(urlString), Category: \(category.rawValue)")
        
        guard let url = URL(string: urlString) else {
            print("❌ API Error: getCountForCategory - Invalid URL: \(urlString)")
            completion(0)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ API Error: getCountForCategory - Network Error: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: getCountForCategory - Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    print("❌ API Error: getCountForCategory - HTTP Error: \(httpResponse.statusCode)")
                    completion(0)
                    return
                }
            } else {
                print("❌ API Error: getCountForCategory - Invalid Response")
                completion(0)
                return
            }
            
            guard let data = data else {
                print("❌ API Error: getCountForCategory - No Data Received")
                completion(0)
                return
            }
            
            print("📦 API Data: getCountForCategory - Received \(data.count) bytes")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let count = json["count"] as? Int {
                    print("✅ API Success: getCountForCategory - Count: \(count) for category: \(category.rawValue)")
                    completion(count)
                } else {
                    print("⚠️ API Warning: getCountForCategory - Could not find count in response")
                    completion(0)
                }
            } catch {
                print("❌ API Error: getCountForCategory - JSON Parsing Error: \(error.localizedDescription)")
                completion(0)
            }
        }.resume()
    }
}
