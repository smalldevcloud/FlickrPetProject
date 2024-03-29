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
        case successLinks(TransportObjectToView)
        case error(Error)
    }
}

class FavouritsViewModel {
    var state = Dynamic<FavouritsVMState>(.loading)
    let flickrWorker = FlickrWorker()
    let defaults = UserDefaultsHelper()
    var photos = [FlickrDomainPhoto]()

    func start() {
        var tempDomainObjects = [FlickrDomainPhoto]()
        state.value = .loading
        var counter = 0 {
            didSet {
                //            счётчик полученных ссылок. пока все ссылки не получены - состояние вью не изменится
                if counter == defaults.array.count {
                    let transportObject = TransportObjectToView(arrOfPhotos: tempDomainObjects, allPages: 0, loadedPages: 0)
                    self.state.value = .successLinks(transportObject)
                }
            }
        }
        defaults.getIds()
        if !defaults.array.isEmpty {
            // если массив избранных фото не пуст - создание домейн-объектов и получение ссылок по ним
            for id in defaults.array {
                flickrWorker.getLink(photoId: id, onResponse: { [weak self] result in
                    let domainPhoto = FlickrDomainPhoto()
                    switch result {
                    case let .success(url):
                        domainPhoto.link = url
                        domainPhoto.id = id
                        domainPhoto.isFavorite = true
                        tempDomainObjects.append(domainPhoto)
                        counter += 1
                    case let .failure(err):
                        self?.state.value = .error(err)
                    }
                })
            }
        } else {
            //            если избранных уже нет - обновление состояния вью
            self.state.value = .successLinks(TransportObjectToView(arrOfPhotos: [], allPages: 0, loadedPages: 0))
        }
    }

    func userDefaultsAction(id: String) {
        //        если нажимается кнопка избранного, то по id ищет фото в массиве. если не было в избранном - добавляет, если было - убирает.
        //        обновляет объект самого фото и отправляет массив снова во вью новым стейтом
        defaults.addIdToUD(id: id)
        start()
    }
}
