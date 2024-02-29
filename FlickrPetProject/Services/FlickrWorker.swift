//
//  FlickrWorker.swift
//  FlickrPetProject
//
//  Created by 8 on 29.02.24.
//

import Foundation

final class FlickrWorker {

    func getPhotos(text: String?, forPage: Int, onResponse: @escaping (Result<TransportObjectToView, Error>) -> Void) {
        Networker.shared.searchRequest(searchText: text, forPage: forPage+1, onResponse: { [weak self] result in
            // нетворкер делает запрос за фотографиями, и в случае успеха объекты преобразуются в более удобные для использования  и сохраняется во вьюмодели
            switch result {
            case let .failure(error):
                onResponse(.failure(error))
            case let .success(response):
                var tempDomainObjects = [FlickrDomainPhoto]()
                var counter = 0 {
                    didSet {
                        // объекты не передаются дальше, пока для каждого фото из пачки не будет получена ссылка
                        if counter == tempDomainObjects.count {
                            let transportObject = TransportObjectToView(arrOfPhotos: tempDomainObjects, allPages: response.photos.pages, loadedPages: response.photos.page)
                            onResponse(.success(transportObject))
                        }
                    }
                }

                for item in response.photos.photo {
                    // получение прямых ссылок на картинку для каждого фото. пока все ссылки не будут получены - состояние вью не изменится.
                    // счётчик увеличивается благодаря замыканию, которое срабатывает при успешном получении ссылки. А когда кол-во ссылок
                    // = кол-ву элементов в перебираемом массиве - состояние вью меняется и оно начинает подгружать фото по полученным ссылкам
                    let newPhoto = item.toDomainObject()

                    self?.getLink(photoId: newPhoto.id, completionHandler: { result in
                        switch result {
                        case let .success(url):
                            newPhoto.link = url
                            counter += 1
                        case let .failure(err):
                            onResponse(.failure(ApiError(message: "can't get links for all images, \(err)")))
                        }
                    })
                    tempDomainObjects.append(newPhoto)
                }
            }
        })
    }

    func getLink(photoId: String, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        Networker.shared.getMediumSizeLinks(photoID: photoId, onResponse: { result in
            switch result {
            case let .success(url):
                completionHandler(.success(url))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        })
    }
}
