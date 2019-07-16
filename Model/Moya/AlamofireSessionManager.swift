//
// Created by ac on 2019-07-16.
// Copyright (c) 2019 Fin. All rights reserved.
//

import Foundation
import Alamofire

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 5 // as seconds, you can set your request timeout
        return DefaultAlamofireManager(configuration: configuration)
    }()
}