//
//  Networker.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//

import Foundation
final class Networker {
//    синглтон для работы с сетью
    static let shared = Networker()
    
    private init() {}

    func buildRequest(apiMethod: FlickrAPIMetod, param: String?, page: Int) -> URLRequest {
//        функция собирает ссылку, по которой будет производится запрос
//        param должен принимать айди фото в случае запроса за фотографией, либо строку поискового запроса, в случае поиска
        var queryItems = [
            URLQueryItem(name: "format", value: Texts.NetworkerEnum.format),
            URLQueryItem(name: "method", value: apiMethod.rawValue),
            URLQueryItem(name: "api_key", value: Texts.NetworkerEnum.apiKey),
            URLQueryItem(name: "nojsoncallback", value: Texts.NetworkerEnum.noJsonCallback)
        ]
        
        switch apiMethod {
        case .Photos:
            queryItems.append(URLQueryItem(name: "user_id", value: Texts.NetworkerEnum.userID))
            queryItems.append(URLQueryItem(name: "per_page", value: Texts.NetworkerEnum.itemsPerPage))
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        case .GetSizes:
            queryItems.append(URLQueryItem(name: "photo_id", value: param))
        case .Search:
            queryItems.append(URLQueryItem(name: "text", value: param))
            queryItems.append(URLQueryItem(name: "per_page", value: Texts.NetworkerEnum.itemsPerPage))
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            queryItems.append(URLQueryItem(name: "media", value: "photos"))
        }

        var urlComps = URLComponents(string: "https://flickr.com/services/rest/")!
        urlComps.queryItems = queryItems
        let result = urlComps.url!
        
        var request = URLRequest(url: result)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func getPhotos(forPage: Int, onResponse: @escaping (Result<FlickrJSONResponse, Error>) -> Void) {

        let request = buildRequest(apiMethod: .Photos, param: "", page: forPage)
//        функция делает запрос списка фотографий
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data,
                  error == nil else {
                onResponse(.failure(error ?? ApiError(message: "Response error")))
                return }
            
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(FlickrJSONResponse.self, from: dataResponse)
                
                DispatchQueue.main.async {
                    onResponse(.success(model))
                }
                
            } catch let parsingError {
                onResponse(.failure(parsingError))
            }
        }
        task.resume()
    }
    
    func getMediumSizeLinks(photoID: String, onResponse: @escaping (Result<URL, Error>) -> Void) {
//        функция получает ссылки на разные размеры конкретной фотографии
        let request = buildRequest(apiMethod: .GetSizes, param: photoID, page: 0)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data,
                  error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return }
            
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(FlickrSizesResponse.self, from: dataResponse)
                DispatchQueue.main.async {
                    var link = URL(string: model.sizes.size[0].url)
                    for item in model.sizes.size {
                        if item.label == .Medium {
                            guard let jsonUrl = URL(string: item.source) else { return }
                            link = jsonUrl
                        } else if item.label == .Original {
                            guard let jsonUrl = URL(string: item.source) else { return }
                            link = jsonUrl
                        }
                    }
                    onResponse(.success(link!))
                }
                
            } catch let parsingError {
                onResponse(.failure(parsingError))
            }
        }
        task.resume()
    }
    
    func searchRequest(searchText: String, forPage: Int, onResponse: @escaping (Result<FlickrJSONResponse, Error>) -> Void) {
        let request = buildRequest(apiMethod: .Search, param: searchText, page: forPage)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data,
                  error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(FlickrJSONResponse.self, from: dataResponse)
                
                DispatchQueue.main.async {
                    onResponse(.success(model))
                }
            } catch let parsingError {
                print("Parsing error", parsingError)
            }
        }
        task.resume()
    }
}
