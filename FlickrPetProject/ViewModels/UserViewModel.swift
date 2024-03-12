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
        case successLinks(TransportObjectToView)
        case error(Error)
    }
}

class UserViewModel {

    var state = Dynamic<UserVMState>(.loading)
    let flickrWorker = FlickrWorker()
    var photos = [FlickrDomainPhoto]()
    var pagesLoaded = 0
    var allPagesCount = 0

    func start() {
        if pagesLoaded <= allPagesCount {
//            еcли загружено меньше страниц, чем их есть - запрос в сеть за новой
            flickrWorker.getPhotos(text: nil, forPage: pagesLoaded+1, onResponse: { [weak self] result in
                switch result {
                case let .success(transportObj):
                    self?.pagesLoaded = transportObj.loadedPages
                    self?.allPagesCount = transportObj.allPages
                    for photo in transportObj.arrOfPhotos {
                        self?.photos.append(photo)
                    }
                    let newTransportObj = TransportObjectToView(arrOfPhotos: self?.photos ?? [], allPages: self?.allPagesCount ?? 0, loadedPages: self?.pagesLoaded ?? 0)
                    self?.state.value = .successLinks(newTransportObj)
                case let .failure(error):
                    self?.state.value = .error(error)
                }
            })
        }
    }
}
