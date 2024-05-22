//
//  NetworkService.swift
//  Solayk
//
//

import Foundation
import Network


class APIService {
    static let shared = APIService()
    private var baseURL = "https://www.solayk.com/api"
    private var bearerToken: String?
    private init() {} // Private initializer
    func setBearerToken(_ token: String) {
        bearerToken = token
    }
    
    func logBearer() -> String? {
        return bearerToken
    }
    
    func fetch<T: Decodable>(_ type: T.Type, endpoint: String, token: String? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.badURL
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = bearerToken ?? token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse, !(200 ... 299).contains(response.statusCode) {
            throw APIError.badResponse(statusCode: response.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(type, from: data)
            return result
        } catch {
            print(error)
            throw APIError.parsing(error as? DecodingError)
        }
    }
    
    @discardableResult
    func post<U: Decodable>(_ type: U.Type, endpoint: String, body: [String: Any] = [:] ) async throws -> U? {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = bearerToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        } catch {
            throw APIError.parsing(nil)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let response = response as? HTTPURLResponse, !(200 ... 299).contains(response.statusCode) {
                if (400 ... 450).contains(response.statusCode) {
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let result = try decoder.decode(ErrorResponse.self, from: data)
                        throw APIError.validationError(result)
                    }
                }
                
                throw APIError.badResponse(statusCode: response.statusCode)
            }
                if data.isEmpty {
                    return nil
                }
                let decoder = JSONDecoder()
                return try decoder.decode(type, from: data)
        } catch {
            throw error
        }
    }
    
}
    
//
//
//struct NetworkStatus {
//
//    static let shared = NetworkStatus()
//
//    static var isConnectedToNetwork: Bool = false
//    let monitor = NWPathMonitor()
//
//    init(){
//        monitor.pathUpdateHandler = { path in
//            if path.status == .satisfied {
//                print("Internet connection is available.")
//                // Perform actions when internet is available
//                NetworkStatus.isConnectedToNetwork = true
//            } else {
//                print("Internet connection is not available.")
//                // Perform actions when internet is not available
//                NetworkStatus.isConnectedToNetwork = false
//
//            }
//        }
//    }
//
//
//}
//

struct EmptyResponse: Decodable {
    // No properties because the response is expected to be empty
}

enum APIError: Error, CustomStringConvertible {
    case badURL
    case badResponse(statusCode: Int)
    case url(URLError?)
    case parsing(DecodingError?)
    case validationError(ErrorResponse)
    case unknown
    
    
    var fullError: Error? {
        switch self {
        case .validationError(let errorResponse):
            return errorResponse
        case .url(let error):
            return error
        case .parsing(let error):
            return error
        case .badResponse, .badURL, .unknown:
            return nil
        }
    }
    

    var localizedDescription: String {
        // user feedback
        switch self {
        case .badURL, .parsing, .unknown:
            return "Sorry, something went wrong."
        case .badResponse:
            return "Sorry, validation error"
        case .url(let error):
            return error?.localizedDescription ?? "Something went wrong."
        case .validationError(let errorResponse):
            return errorResponse.message
        }
    }

    var description: String {
        // info for debugging
        switch self {
        case .unknown: return "unknown error"
        case .badURL: return "invalid URL"
        case .url(let error):
            return error?.localizedDescription ?? "url session error"
        case .parsing(let error):
            return "parsing error \(error?.localizedDescription ?? "")"
        case .badResponse(statusCode: let statusCode):
            return "bad response with status code \(statusCode)"
        case .validationError(let errorResponse):
            return "validation error: \(errorResponse.message)"
        }
    }
}

struct ErrorResponse: Codable,Error {
    let code: String
    let message: String
    let errors: [FieldError]?
}

struct FieldError: Codable {
    let field: String
    let message: String
    let code: String
}


func getApiError(apiError: APIError) -> ErrorResponse? {
    switch apiError {
    case .validationError(let errorResponse):
        return errorResponse
    default:
        return nil
    }
}
