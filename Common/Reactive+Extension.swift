//
// Created by ac on 2019-06-26.
// Copyright (c) 2019 Fin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

public extension Reactive where Base: MoyaProviderType {

    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single response object.
    func custom_request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Response> {
        return Single.create { [weak base] single in
            let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    let code = response.statusCode
                    if(code != 200){
                        if let msg = response.response?.allHeaderFields["msg-content"] as? String{
                            let errmsg = MyError(msg:msg.removingPercentEncoding!)
                            single(.error(errmsg))
                        }
                        else{
                            let errmsg = MyError(msg:"服务异常")
                            single(.error(errmsg))
                        }
                    }
                    else{
                        single(.success(response))
                    }
                case let .failure(error):
                    single(.error(error))
                }
            }

            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}

public struct MyError:LocalizedError {
    let msg: String

    public var localizedDescription: String { return self.msg }
    public var errorDescription: String? { return self.msg }

    func rawString() -> String {
        return self.msg
    }
}
