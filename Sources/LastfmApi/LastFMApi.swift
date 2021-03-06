import Foundation
import RxSwift
import RxAlamofire
import Alamofire

public class LastFMApi {
    public enum ApiError: Error {
        case notFound
        case missingData
        case invalidRequest
        case invalidResponse
    }

    let apiKey: String
    private let url = "https://ws.audioscrobbler.com/2.0/"
    private let encoding = URLEncoding.default
    private let headers: HTTPHeaders
    
    /// Initialize a LastFMApi object
    /// - Parameters:
    ///   - apiKey: your last.fm api key
    ///   - userAgent: the userAgent to report to last.fm
    public init(apiKey: String, userAgent: String) {
        self.apiKey = apiKey
        headers = HTTPHeaders([HTTPHeader(name: "Content-Type", value: "application/json"),
                               HTTPHeader(name: "User-Agent", value: userAgent)])
    }
    
    typealias RequestResult = Swift.Result<(HTTPURLResponse, Data), ApiError>
    func dataPostRequest(parameters: [String: Any]) -> Observable<RequestResult> {
        return RxAlamofire.requestData(.get, url, parameters: parameters, encoding: encoding, headers: headers)
            .flatMapFirst { (arg) -> Observable<RequestResult> in
                let (response, data) = arg
                guard response.statusCode == 200, (response.mimeType ?? "").contains("json") else {
                    return Observable.just(.failure(.invalidRequest))
                }
                return Observable.just(.success((response, data)))
            }
    }
}

