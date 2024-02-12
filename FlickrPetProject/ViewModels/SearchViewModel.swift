//
//  SearchViewModel.swift
//  FlickrPetProject
//
//  Created by 8 on 19.01.24.
//

import Foundation

extension SearchViewModel {
    enum SearchVMState {
        case loading
        case successPhotos
        case error(Error)
    }
}

class SearchViewModel {
    var state = Dynamic<SearchVMState>(.loading)
    var photos = [FlickrDomainPhoto]()
    var pagesLoaded = 0
    var allPagesCount = 0
    var textForSearch = ""
    
    func start() {

        if pagesLoaded <= allPagesCount {

            Networker.shared.searchRequest(searchText: textForSearch, forPage: pagesLoaded+1, onResponse: { [weak self] result in
                //            нетворкер делает запрос за фотографиями, и в случае успеха объекты преобразуются в более удобные для использования  и сохраняется во вьюмодели
                switch result {
                    
                case let .failure(error):
                    self?.state.value = .error(error)
                case let .success(response):

                    var tempDomainObjects = [FlickrDomainPhoto]()
                    var counter = 0 {
                        didSet {
//                          объекты не передаются дальше, пока для каждого фото из пачки не будет получена ссылка
                            if counter == tempDomainObjects.count {
                                self?.pagesLoaded = response.photos.page
                                self?.allPagesCount = response.photos.pages
                                self?.state.value = .successPhotos
                            } else {
                               
                            }
                        }
                    }
                    
                    for item in response.photos.photo {
//                        получение прямых ссылок на картинку для каждого фото. пока все ссылки не будут получены - состояние вью не изменится. счётчик увеличивается благодаря замыканию, которое срабатывает при успешном получении ссылки. А когда кол-во ссылок = кол-ву элементов в перебираемом массиве - состояние вью меняется и оно начинает подгружать фото по полученным ссылкам
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
    
    func clearForNewSearchQuery() {
//        убирает всё лишнее, чтобы грузить новые фото с нуля, не продолжая в старую выборку. вызывается если новый запрос отличается от старого
        photos = []
        pagesLoaded = 0
        allPagesCount = 0
        state.value = .loading
    }
}
