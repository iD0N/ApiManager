//
//  ApiManagerDelegate.swift
//  ApiManager
//
//  Created by Don on 2/27/20.
//  Copyright © 2020 Don. All rights reserved.
//

import Foundation
import Alamofire

protocol ApiManagerDelegate {
    
	func apiManager(_ apiManager: ApiManager,
                              shouldFinishRequest request: URLRequest) -> Bool
	
}
extension ApiManagerDelegate
{
	func apiManager(_ apiManager: ApiManager,
					shouldFinishRequest request: URLRequest) -> Bool {
		true
	}
}
