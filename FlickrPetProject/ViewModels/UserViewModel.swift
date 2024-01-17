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
        case successPhotos
        case successLinks
        case error(Error)
    }
}

class UserViewModel {
    
    var state = Dynamic<UserVMState>(.loading)
    let networker = Networker()
    var photos = [FlickrPhoto]()
    var links: [URL] = []
    var pagesLoaded = 0
    var allPagesCount = 0
    
    func start() {
        networker.getPhotos(forPage: pagesLoaded+1, onResponse: { [weak self] result in
            //            нетворкер делает запрос за фотографиями, и в случае успеха ответ сервера передаётся уже во вью вместе со стейтом для отображения
            
            switch result {
                
            case let .failure(error):
                self?.state.value = .error(error)
            case let .success(response):
//                self?.photos.append(contentsOf: response.photos.photo.sorted(by: { $0.id > $1.id }))
                self?.photos.append(contentsOf: response.photos.photo)
                self?.pagesLoaded = response.photos.page
                self?.allPagesCount = response.photos.pages
                self?.state.value = .successPhotos
                self?.getLinks(photosForLinks: response.photos.photo)
            }
        })
    }
    
    func getLinks(photosForLinks: [FlickrPhoto]) {
        
        var linksForLoop: [URL] = [] {
            didSet {
                //                как только получены ссылки по всем фото - изменение стейта приложения
                if linksForLoop.count == photosForLinks.count {
                    
                    for link in linksForLoop {
                        self.links.append(link)
                    }
                    self.state.value = .successLinks
                }
            }
        }
        
        for photo in photosForLinks {
            //            получение ссылки на картинку среднего размера по каждой из фотографий
            networker.getMediumSizeLinks(photoID: photo.id, onResponse: { result in
                linksForLoop.append(result)
            })
        }
    }
}
