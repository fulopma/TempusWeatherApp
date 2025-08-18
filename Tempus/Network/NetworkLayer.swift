//
//  NetworkLayer.swift
//  Tempus
//
//  Created by Marcell Fulop on 8/14/25.
//
import NewRelic
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case decodingFailed
    // no response from server
    case fetchFailed
    // server responds but with error (5xx)
    case invalidFetchCode
}
public enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}
protocol Request {
    var baseURL: String { get set }
    var path: String { get set }
    var httpMethod: HttpMethod { get set }
    var params: [String: String] { get set }
    var header: [String: String] { get set }
}
extension Request {
    func createRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: baseURL + path)
        urlComponents?.queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        guard let url = urlComponents?.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = header
        return urlRequest
    }
}
protocol Networking {
    func execute<T: Decodable>(request: Request, modelName: T.Type, retries left: Int) async throws
        -> T
}
final class NetworkManager: Networking {
    private let urlSession: URLSession
    init() {
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
    }
    func execute<T>(request: any Request, modelName: T.Type, retries left: Int = 3) async throws -> T
    where T: Decodable {
        guard let urlRequest = request.createRequest() else {
            throw NetworkError.invalidURL
        }
        let timer = NRTimer()
        let data: Data
        var response: URLResponse?
        let requestedUrl: URL? = urlRequest.url
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode {
                timer.stop()
                NewRelic.noticeNetworkRequest(
                    for: requestedUrl,
                    httpMethod: urlRequest.httpMethod,
                    with: timer,
                    responseHeaders: httpResponse.allHeaderFields,
                    statusCode: httpResponse.statusCode,
                    bytesSent: 0,
                    bytesReceived: UInt(data.count),
                    responseData: data,
                    traceHeaders: nil,
                    andParams: nil
                )
            } else if let httpResponse = response as? HTTPURLResponse {
                timer.stop()
                NewRelic.noticeNetworkFailure(
                    for: requestedUrl,
                    httpMethod: urlRequest.httpMethod,
                    with: timer,
                    andFailureCode: httpResponse.statusCode
                )
                // too many fetches try again
                if left > 0 && httpResponse.statusCode == 429 {
                    try await Task.sleep(for: .seconds(1.0/Double(left)))
                    return try await execute(request: request, modelName: modelName, retries: left - 1)
                }
                throw NetworkError.invalidFetchCode
            }
        }
        guard let _ = response else {
            timer.stop()
            NewRelic.noticeNetworkFailure(
                for: requestedUrl,
                httpMethod: urlRequest.httpMethod,
                with: timer,
                andFailureCode: (response as? HTTPURLResponse)?.statusCode ?? 500
            )
            throw NetworkError.fetchFailed
        }
        do {
            return try JSONDecoder().decode(modelName.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
