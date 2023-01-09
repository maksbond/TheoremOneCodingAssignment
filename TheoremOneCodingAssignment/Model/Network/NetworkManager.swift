//
//  NetworkManager.swift
//  TheoremOneCodingAssignment
//
//  Created by Maksym Bondar on 07.01.2023.
//

import Foundation
import os.log

class NetworkManager: Networking {
    // Session object used for requests
    private let session: URLSession
    
    private let log: OSLog

    // Base path used for requests
    private let basePath = "https://jsonplaceholder.typicode.com"
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
        self.log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "NetworkManager")
    }
    
    func fetchPosts() async throws -> [Post] {
        guard let request = generateRequest(for: .posts(nil), method: .get) else {
            throw NetworkManagerError.invalidURL
        }
        return try await fetchData(with: request, type: [Post].self)
    }
    
    func fetchUser(for post: Post) async throws -> User {
        guard let request = generateRequest(for: .users(post.userId), method: .get) else {
            throw NetworkManagerError.invalidURL
        }
        return try await fetchData(with: request, type: User.self)
    }
    
    func fetchComments(for post: Post) async throws -> [Comment] {
        guard let request = generateRequest(for: .comments(post.id), method: .get) else {
            throw NetworkManagerError.invalidURL
        }
        return try await fetchData(with: request, type: [Comment].self)
    }
    
    func delete(post: Post) async throws {
        guard let request = generateRequest(for: .posts(post.id), method: .delete) else {
            throw NetworkManagerError.invalidURL
        }
        try await fetchData(with: request)
    }
}

// MARK: - Private Helpers

private extension NetworkManager {
    enum APIEndpoint {
        case comments(UInt64)
        case users(UInt64)
        case posts(UInt64?)
        
        var components: [String] {
            var components = [String]()
            switch self {
            case .posts(let postId):
                components.append("posts")
                guard let postId = postId else {
                    return components
                }
                components.append("\(postId)")
            case .comments(let postId):
                components.append(contentsOf: ["posts", "\(postId)", "comments"])
            case .users(let userId):
                components.append(contentsOf: ["users", "\(userId)"])
            }
            return components
        }
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    /**
     Generate URLRequest for API call
     
     - parameters:
        - for: API endpoint
        - method: HTTP method
        - headers: HTTP headers. Nullable
        - body: HTTP body data. Nullable
     - returns: In case of successful work it returns URLRequest, otherwise - nil
     */
    func generateRequest(for endPoint: APIEndpoint, method: HTTPMethod, headers: [String: String]? = nil, body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: basePath) else {
            return nil
        }
        var fullURL = url
        for component in endPoint.components {
            if #available(iOS 16.0, *) {
                fullURL = fullURL.appending(component: component)
            } else {
                fullURL = fullURL.appendingPathComponent(component)
            }
        }
        // Generate request
        var request = URLRequest(url: fullURL)
        // Set http method
        request.httpMethod = method.rawValue
        // Add http body only for post, put and patch methods
        switch method {
        case .post, .put, .patch:
            request.httpBody = body
        default:
            break
        }
        // Add default headers
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        // Add headers passed to function
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        os_log(.info, log: log, "\n++++++\nGenerated request: %{public}@\nMethod: %{public}@\nHeaders: %{public}@\nBody: %{public}@\n++++++\n", request.url?.absoluteString ?? "", method.rawValue, request.allHTTPHeaderFields ?? [:], body == nil ? "nil" : "not nil")
        return request
    }

    @discardableResult
    func fetchData(with request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkManagerError.invalidResponseConverting
        }
        os_log(.info, log: log, "\n++++++\nRequest URL: %{public}@\nResponse status code: %{public}d\n++++++\n", request.url?.absoluteString ?? "", httpResponse.statusCode)
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkManagerError.unauthorizedRequest
        default:
            throw NetworkManagerError.invalidStatusCode
        }
        return data
    }
    
    func fetchData<T: Decodable>(with request: URLRequest, type: T.Type) async throws -> T {
        let data = try await fetchData(with: request)
        do {
            let result = try JSONDecoder().decode(type, from: data)
            return result
        } catch {
            throw NetworkManagerError.decoding(error: error)
        }
    }
}

// MARK: - NetworkManagerError

extension NetworkManager {
    enum NetworkManagerError: Error, CustomStringConvertible, Equatable {
        static func == (lhs: NetworkManager.NetworkManagerError, rhs: NetworkManager.NetworkManagerError) -> Bool {
            return lhs.description == rhs.description
        }
        
        case invalidURL
        case invalidResponseConverting
        case invalidStatusCode
        case unauthorizedRequest
        case decoding(error: Error)

        var description: String {
            switch self {
            case .invalidURL:
                return "Can't generate URL"
            case .invalidResponseConverting:
                return "Can't convert URLResponse to HTTPURLReponse"
            case .invalidStatusCode:
                return "Unhandle HTTP status code"
            case .unauthorizedRequest:
                return "Unauthorized request"
            case .decoding(let error):
                return "Can't decode response data. Error: \(error.localizedDescription)"
            }
        }
    }
}
