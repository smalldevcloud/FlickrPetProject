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
        case success(FlickrJSONResponse)
        case error(Error)
    }
}

class UserViewModel {
    
    var state = Dynamic<UserVMState>(.loading)
    
    let networker = Networker()
    
    func start() {
        networker.getPhotos(onResponse: { [weak self] result in
//            нетворкер делает запрос за фотографиями, и в случае успеха ответ сервера передаётся уже во вью вместе со стейтом для отображения
            switch result {
            case let .success(photosResponse):
                self?.state.value = .success(photosResponse)
            case let .failure(error):
                self?.state.value = .error(error)
            }
            
        })
    }
    
}
