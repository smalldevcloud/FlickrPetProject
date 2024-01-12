//
//  Networker.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//

import Foundation
final class Networker {

    func buildRequest(apiMethod: FlickrAPIMetod, photoId: String?) -> URLRequest {
//        функция собирает ссылку, по которой будет производится запрос
        var queryItems = [
            URLQueryItem(name: "format", value: Texts.NetworkerEnum.format),
            URLQueryItem(name: "method", value: apiMethod.rawValue),
            
            URLQueryItem(name: "api_key", value: Texts.NetworkerEnum.apiKey),
            URLQueryItem(name: "nojsoncallback", value: Texts.NetworkerEnum.noJsonCallback)
        ]
        if apiMethod == .Photos {
            queryItems.append(URLQueryItem(name: "user_id", value: Texts.NetworkerEnum.userID))
        } else {
            queryItems.append(URLQueryItem(name: "photo_id", value: photoId))
        }
        var urlComps = URLComponents(string: "https://flickr.com/services/rest/")!
        urlComps.queryItems = queryItems
        let result = urlComps.url!
        
        var request = URLRequest(url: result)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func getPhotos(onResponse: @escaping (Result<FlickrJSONResponse, Error>) -> Void) {

        let request = buildRequest(apiMethod: .Photos, photoId: "")
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
    
    func getMediumSizeLinks(photoID: String, onResponse: @escaping (URL) -> Void) {
//        функция получает ссылки на разные размеры конкретной фотографии
        let request = buildRequest(apiMethod: .GetSizes, photoId: photoID)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data,
                  error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return }
            
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(FlickrSizesResponse.self, from: dataResponse)
                
                DispatchQueue.main.async {
                    for item in model.sizes.size {
                        if item.label == .Medium {
                            guard let jsonUrl = URL(string: item.source) else { return }

                            onResponse(jsonUrl)
                        }
                    }
                }
            } catch let parsingError {
                print("Parsing sizes error", parsingError)

            }
        }
        task.resume()
    }
    
    func downloadPhoto(from url: URL, onResponse: @escaping (Data) -> Void) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                onResponse(data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}
