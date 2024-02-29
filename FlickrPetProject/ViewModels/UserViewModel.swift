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

    func start(loadedPagesFromView: Int, availablePages: Int) {

        if loadedPagesFromView <= availablePages {
//            еcли загружено меньше страниц, чем их есть - запрос в сеть за новой
            flickrWorker.getPhotos(text: nil, forPage: loadedPagesFromView, onResponse: { [weak self] result in
                switch result {
                case let .success(transportObj):
                    self?.state.value = .successLinks(transportObj)
                case let .failure(error):
                    self?.state.value = .error(error)
                }
            })
        }
    }
}
