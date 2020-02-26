//
//  ApiManagerErrors.swift
//  ApiManager
//
//  Created by Don on 2/19/20.
//  Copyright © 2020 Don. All rights reserved.
//

import Foundation


public enum NetworkError: Error
{
	case requestTimedOut
	case badURL
	case unAuthorized
	case tokenExpired
	case serverError(Codable)
	case message(String)
	case encodeFailed
	case decodeFailed
}
