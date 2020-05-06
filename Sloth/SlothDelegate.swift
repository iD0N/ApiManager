//
//  SlothDelegate.swift
//  Sloth
//
//  Created by Don on 2/27/20.
//  Copyright © 2020 Don. All rights reserved.
//

import Foundation
import Alamofire

public protocol SlothDelegate {
    
	///Callback when a request fails, you can handle custom server errors here
	func sloth(_ sloth: Sloth, requestFailed request: URLRequest?, error: SlothError) -> SlothError
	
}
extension SlothDelegate
{
	func sloth(_ sloth: Sloth, requestFailed request: URLRequest?, error: SlothError) -> SlothError {
		return error
	}
}
