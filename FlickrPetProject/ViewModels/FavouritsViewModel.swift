//
//  FavouritsViewModel.swift
//  FlickrPetProject
//
//  Created by 8 on 25.01.24.
//

import Foundation

extension FavouritsViewModel {
    enum FavouritsVMState {
        case loading
        case successLinks
        case error(Error)
    }
}

class FavouritsViewModel {
    var state = Dynamic<FavouritsVMState>(.loading)
    var photos = [FlickrDomainPhoto]()
    let defaults = UserDefaultsHelper()

    
    func start() {
        
        state.value = .loading
        var counter = 0 {
            didSet {
//            счётчик полученных ссылок. пока все ссылки не получены - состояние вью не изменится
                if counter == defaults.array.count {
                    self.state.value = .successLinks
                }
            }
        }
        
        defaults.getIds()
        if !defaults.array.isEmpty {
//            если массив избранных фото не пуст - создание домейн-объектов и получение ссылок по ним
            photos.removeAll()
            for id in defaults.array {
                
                Networker.shared.getMediumSizeLinks(photoID: id, onResponse: { result in
                    let domainPhoto = FlickrDomainPhoto()
                    
                    switch result {
                    case let .success(url):
                        domainPhoto.link = url
                        domainPhoto.id = id
                        self.photos.append(domainPhoto)
                        print(result)
                        counter += 1
                    case let .failure(err):
                        self.state.value = .error(err)
                    }
                    
                    
                })
            }
        } else {
//            если избранных уже нет - обновление состояния вью
            photos.removeAll()
            self.state.value = .successLinks

        }
    }
}
