//
//  NetworkManagerTests.swift
//  TheoremOneCodingAssignmentTests
//
//  Created by Maksym Bondar on 09.01.2023.
//

import XCTest
@testable import TheoremOneCodingAssignment

final class NetworkManagerTests: XCTestCase {

    var networkManager: NetworkManager!
    var expectation: XCTestExpectation!
    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        networkManager = NetworkManager(session: urlSession)
        expectation = XCTestExpectation(description: "Successfull call expected")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNetworkManager_NetworkManagerError_descriptions() throws {
        let errors = [
            NetworkManager.NetworkManagerError.invalidURL,
            .invalidResponseConverting,
            .invalidStatusCode,
            .unauthorizedRequest,
            .decoding(error: NetworkManager.NetworkManagerError.invalidURL)
        ]
        let expectedDescriptions = [
            "Can't generate URL",
            "Can't convert URLResponse to HTTPURLReponse",
            "Unhandle HTTP status code",
            "Unauthorized request",
            "Can't decode response data. Error: \(NetworkManager.NetworkManagerError.invalidURL.localizedDescription)"
        ]
        for (index, error) in errors.enumerated() {
            XCTAssertEqual(expectedDescriptions[index], error.description)
        }
    }
    
    func testFetchPosts_Successfully() {
        let data = "posts".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts")
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            let posts = try await networkManager.fetchPosts()
            XCTAssertEqual(posts.count, 100)
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }

    func testFetchUser_Successfully() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        let data = "user".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/users/1")
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            let user = try await networkManager.fetchUser(for: post)
            XCTAssertEqual(user.id, 1)
            XCTAssertEqual(user.name, "Leanne Graham")
            XCTAssertEqual(user.username, "Bret")
            XCTAssertEqual(user.email, "Sincere@april.biz")
            XCTAssertEqual(user.website, "hildegard.org")
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }

    func testFetchComments_Successfully() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        let data = "comments".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts/1/comments")
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            let comments = try await networkManager.fetchComments(for: post)
            XCTAssertEqual(comments.count, 5)
            let comment = comments[0]
            XCTAssertEqual(comment.id, 1)
            XCTAssertEqual(comment.postId, 1)
            XCTAssertEqual(comment.name, "id labore ex et quam laborum")
            XCTAssertEqual(comment.email, "Eliseo@gardner.biz")
            XCTAssertEqual(comment.body, "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium")
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testDeletePost_Successfully() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts/1")
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let task = Task {
            let user = try await networkManager.delete(post: post)
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testFetchPosts_401_StatusCode() {
        let data = "posts".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts")
            let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchPosts()
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.unauthorizedRequest)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }

    func testFetchPosts_500_StatusCode() {
        let data = "posts".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts")
            let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchPosts()
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.invalidStatusCode)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testFetchPosts_DecodingIssue() {
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts")
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchPosts()
            } catch {
                XCTAssertTrue((error as! NetworkManager.NetworkManagerError).description.contains("Can't decode response data. Error:"))
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testFetchUser_401_StatusCode() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        let data = "user".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/users/1")
            let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchUser(for: post)
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.unauthorizedRequest)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testFetchUser_500_StatusCode() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        let data = "user".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/users/1")
            let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchUser(for: post)
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.invalidStatusCode)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }

    func testFetchUser_DecodingIssue() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/users/1")
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchUser(for: post)
            } catch {
                XCTAssertTrue((error as! NetworkManager.NetworkManagerError).description.contains("Can't decode response data. Error:"))
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testFetchComments_401_StatusCode() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        let data = "comments".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts/1/comments")
            let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchComments(for: post)
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.unauthorizedRequest)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testFetchComments_500_StatusCode() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        let data = "comments".data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts/1/comments")
            let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchComments(for: post)
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.invalidStatusCode)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }

    func testFetchComments_DecodingIssue() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts/1/comments")
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let task = Task {
            do {
                let _ = try await networkManager.fetchComments(for: post)
            } catch {
                XCTAssertTrue((error as! NetworkManager.NetworkManagerError).description.contains("Can't decode response data. Error:"))
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testDeletePost_401_StatusCode() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts/1")
            let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let task = Task {
            do {
                let _ = try await networkManager.delete(post: post)
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.unauthorizedRequest)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
    
    func testDetelePost_500_StatusCode() {
        let post = Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                fatalError("InvalidURL")
            }
            XCTAssertEqual(url.absoluteString, "https://jsonplaceholder.typicode.com/posts/1")
            let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let task = Task {
            do {
                let _ = try await networkManager.delete(post: post)
            } catch {
                XCTAssertEqual(error as! NetworkManager.NetworkManagerError, NetworkManager.NetworkManagerError.invalidStatusCode)
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5)
        task.cancel()
    }
}
