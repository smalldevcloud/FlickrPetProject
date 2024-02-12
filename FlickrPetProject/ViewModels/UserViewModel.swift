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
        case successLinks
        case error(Error)
    }
}

class UserViewModel {
    
    var state = Dynamic<UserVMState>(.loading)
    var photos = [FlickrDomainPhoto]()
    var pagesLoaded = 0
    var allPagesCount = 0

    
    func start() {
        
        if pagesLoaded <= allPagesCount {
//            еcли загружено меньше страниц, чем их есть - запрос в сеть за новой
            Networker.shared.getPhotos(forPage: pagesLoaded+1, onResponse: { [weak self] result in
                //            нетворкер делает запрос за фотографиями, и в случае успеха объекты преобразуются в более удобные для использования  и сохраняется во вьюмодели
                switch result {
                    
                case let .failure(error):
                    self?.state.value = .error(error)
                case let .success(response):
                    var tempDomainObjects = [FlickrDomainPhoto]()
                    var counter = 0 {
                        didSet {
//                            объекты не передаются дальше, пока для каждого фото из пачке не будет получена ссылка
                            if counter == tempDomainObjects.count {
                                self?.pagesLoaded = response.photos.page
                                self?.allPagesCount = response.photos.pages
                                self?.state.value = .successLinks
                            } else {
                                
                            }
                        }
                    }
                    
                    for item in response.photos.photo {
//                        получение прямых ссылок на картинку для каждого фото
                        let newPhoto = item.toDomainObject()
                        newPhoto.getLink(completionHandler: { [weak self] response in
                            if response == true {
                                counter += 1
                            } else {
                                print("==========error============")
                            }
                        })
                        self?.photos.append(newPhoto)
                        tempDomainObjects.append(item.toDomainObject())
                    }
                }
            })
        }
    }
}
