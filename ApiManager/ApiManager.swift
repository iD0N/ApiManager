//
//  ApiManager.swift
//  ApiManager
//
//  Created by Don on 6/19/19.
//  Copyright © 2019 Don. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit


public class ApiManager {
	
	public typealias APIPromise<T: Codable> = Promise<T>
	

	/// server baseURL
	public var baseURL: String
	
	/// API Versioning configuration
	public var apiVersion: String?
	
	/// refresh token to use when refreshing
	public var refreshToken: String?
	
	/// Authentication token
	public var token: String?
	
	/// Private encoder for requests with encodable model
	public var encoder = JSONEncoder()
	
	/// Private decoder for decoding requests response
	public var decoder = JSONDecoder()
	
	/// Alamofire session
	public var session: SessionManager
	
	
	/// initialize with baseURL only
	public init(_ baseURL: String) {
		self.baseURL = baseURL
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForResource = 10 // seconds
		configuration.timeoutIntervalForRequest = 10
		self.session = SessionManager(configuration: configuration)
	}
	
	/// initialize with baseURL and custom session
	public init(_ baseURL: String, session: SessionManager) {
		self.baseURL = baseURL
		self.session = session
	}
	/// Request with dictionary parameters
	public func request<T:Codable>(_ to: String, method: HTTPMethod, params: [String : Any]?, resultType: T.Type) -> APIPromise<T> {
		
		self.session
		.request(absolutePath(to), method: method, parameters: params, encoding: method == .get ? URLEncoding.queryString : URLEncoding.httpBody, headers: generatedHeader(authenticate: true))
			.responseData()
			.map({ (result) -> T in
				
				let (_, response) = result
				let decoded : T = try self.handleResponse(response)
				return decoded
				
			})
	}
}

// MARK: - URL and Header generation

extension ApiManager
{
	func generatedHeader(authenticate: Bool) -> [String: String] {
		
		var headers = ["content-type": "application/json",
				   "cache-control": "no-cache"]
		if let version = self.apiVersion
		{
			headers["Api-Version"] = version
		}
		if authenticate, let token = self.token
		{
			let auth = "Bearer \(token)".replacingOccurrences(of: "\"", with: "")
			headers["Authorization"] = auth
		}
		return headers
	}
	func absolutePath(_ relative: String) -> String {
		return self.baseURL + relative
	}
	func absoluteURL(_ relative: String) -> URL {
		return URL(string: self.baseURL + relative)!
	}

}

//MARK: - Response Handler

extension ApiManager
{
	func handleResponse<T:Codable>(_ response: PMKAlamofireDataResponse) throws -> T  {
		guard let statusCode = response.response?.statusCode
			else {
				throw NetworkError.requestTimedOut
		}
		switch statusCode
		{
		case 200...210:
			do {

				guard let stuff = response.data
					else {
						print("⚠️ No data response for: \(response.request?.url?.absoluteString ?? "") found")
						throw NetworkError.decodeFailed
				}
				let callbackData = try self.decoder.decode(T.self, from: stuff)
				return callbackData
			}
			catch {

				print(error)
				print("⚠️ Decoding: \(response.request?.url?.absoluteString ?? "") response Failed")
				throw NetworkError.decodeFailed
			}
		case 400:
			throw NetworkError.badURL

		default:
			//❗️⭕️🛑🆘❌‼️⚠️✅🔴🔜🔺
			print("❌ Endpoint: \(response.request?.url?.absoluteString ?? "") Failed")
			print(response.response ?? "🛑 Response empty")
			print(response.request ?? "🛑 Request empty")
			print(String(data: response.data ?? Data(), encoding: .utf8) ?? "🛑 response data empty")
			throw NetworkError.badURL
		}
	}
}
