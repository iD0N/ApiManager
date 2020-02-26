//
//  ApiManager.swift
//  ApiManager
//
//  Created by Don on 6/19/19.
//  Copyright © 2019 Don. All rights reserved.
//

import Foundation
import Alamofire


public class DummyCodable: Codable
{ }

public class ApiManager {

	public typealias ResultCompletion<T> = ((CompletionType<T>) -> ())
	
	public typealias CompletionType<T> = Swift.Result<T, NetworkError>

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
	/// Request with codable parameter
	public func request<P:Codable, T:Codable>(_ to: String, method: HTTPMethod, paramData: P, callback: @escaping ResultCompletion<T?>) {
		do {
			let encodedParam = try encoder.encode(paramData)
			
			var request = URLRequest(url: absoluteURL(to))
			request.httpMethod = method.rawValue
			
			for (key, value) in generatedHeader(authenticate: true)
			{
				request.addValue(value, forHTTPHeaderField: key)
			}
			request.httpBody = encodedParam
			
			self.session.request(request).responseData { (response) in
				callback(self.handleResponse(response))
				
			}
		}
		catch
		{
			callback(.failure(.encodeFailed))
		}
	}
	/// Request with dictionary parameters
	public func request<T:Codable>(_ to: String, method: HTTPMethod, params: [String : Any]?, resultType: T.Type, callback: @escaping ResultCompletion<T?>) {
		
		self.session.request(absolutePath(to), method: method, parameters: params, encoding: method == .get ? URLEncoding.queryString : JSONEncoding.default, headers: generatedHeader(authenticate: true)).responseData { (response) in
			callback(self.handleResponse(response))
		}
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
	func handleResponse<T:Codable>(_ response: DataResponse<Data>) -> Swift.Result<T?, NetworkError>  {
		guard let statusCode = response.response?.statusCode
			else {
			return .failure(.requestTimedOut)
		}
		switch statusCode
		{
		case 200...210:
			do {

				guard let stuff = response.data
					else {
						print("⚠️ No data response for: \(response.request?.url?.absoluteString ?? "") found")
						return .success(nil)
				}
				let callbackData = try self.decoder.decode(T.self, from: stuff)
				return .success(callbackData)
			}
			catch {

				print(error)
				print("⚠️ Decoding: \(response.request?.url?.absoluteString ?? "") response Failed")
				return(.success(nil))
			}
		case 400:
			return(.failure(.badURL))
//			guard let stuff = response.data, let parseModel = errorParseModel
//				else {
//					return .failure(.badURL)
//			}
//			/// - HANDLE server error messages
//			do {
//				let callbackData = try decoder.decode(parseModel.self, from: stuff)
//				return .failure(.serverError(callbackData))
//			}
//			catch {
//
//				print("⚠️ Decoding: \(response.request?.url?.absoluteString ?? "") error response Failed")
//				return(.failure(.decodeFailed))
//			}

		default:
			//❗️⭕️🛑🆘❌‼️⚠️✅🔴🔜🔺
			print("❌ Endpoint: \(response.request?.url?.absoluteString ?? "") Failed")
			print(response.response ?? "🛑 Response empty")
			print(response.result)
			print(response.request ?? "🛑 Request empty")
			print(String(data: response.data ?? Data(), encoding: .utf8) ?? "🛑 response data empty")
			return .failure(.badURL)
		}
	}
}
//MARK: - Upload Management

extension ApiManager
{
	public func upload<T:Codable>(_ to: String, data: Data, name: String = "images", callback: @escaping ResultCompletion<T?>) {
		
		let guid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
		self.session.upload(multipartFormData: { (MultipartFormData) in
			
			MultipartFormData.append(data, withName: name, fileName: "\(guid).jpg", mimeType: "image/jpeg/mp4/jpg/png")
			
		}, usingThreshold: .max, to: absolutePath(to), method: .post, headers: generatedHeader(authenticate: true), queue: nil) { (result) in
			
			switch result
			{
			case .success(let upload, _, _):
				upload.responseData { [unowned self] (response) in
					callback(self.handleResponse(response))
				}
			case .failure(_):
				callback(.failure(.badURL))
			}
		}
	}
}
