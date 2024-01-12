//
//  UserViewModel.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//

import Foundation

extension UserViewModel {
//    описания возможных состояний для этой вьюмодели (и впоследствии для вью)
    enum UserVMState {
        case loading
        case successPhotos(FlickrJSONResponse)
        case successLinks([URL])
        case error(Error)
    }
}

class UserViewModel {
    
    var state = Dynamic<UserVMState>(.loading)
    
    let networker = Networker()
    
    var photos: [FlickrPhoto]? {
        didSet {
//            как только список фото появился - запрос на получение ссылок
            getLinks()
        }
    }
    
    func start() {
        networker.getPhotos(onResponse: { [weak self] result in
//            нетворкер делает запрос за фотографиями, и в случае успеха ответ сервера передаётся уже во вью вместе со стейтом для отображения
            switch result {

            case let .failure(error):
                self?.state.value = .error(error)
            case let .success(response):
                self?.photos = response.photos.photo
                self?.state.value = .successPhotos(response)
            }
        })
    }
    
    func getLinks() {

        var links: [URL] = [] {
            didSet {
//                как только получены ссылке по всем фото - изменение стейта приложения, которое требует передать список ссылок
                if links.count == photos?.count {
                    self.state.value = .successLinks(links)
                }
            }
        }
        
        for photo in photos! {
//            получение ссылки на картинку среднего размера по каждой из фотографий
            networker.getMediumSizeLinks(photoID: photo.id, onResponse: { result in
                links.append(result)
            })
        }
        
        
    }
}
