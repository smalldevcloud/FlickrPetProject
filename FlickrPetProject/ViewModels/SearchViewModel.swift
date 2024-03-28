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
        case successLinks(TransportObjectToView)
        case error(Error)
    }
}

class SearchViewModel {
    var state = Dynamic<SearchVMState>(.loading)
    let flickrWorker = FlickrWorker()
    let defaults = UserDefaultsHelper()
    var photos = [FlickrDomainPhoto]()
    var pagesLoaded = 0
    var allPagesCount = 0

    func start(searchQuery: String) {
        if pagesLoaded <= allPagesCount {
            //            еcли загружено меньше страниц, чем их есть - запрос в сеть за новой
            flickrWorker.getPhotos(text: searchQuery, forPage: pagesLoaded+1, onResponse: { [weak self] result in
                switch result {
                case let .success(transportObj):
                    self?.pagesLoaded = transportObj.loadedPages
                    self?.allPagesCount = transportObj.allPages
                    for photo in transportObj.arrOfPhotos {
                        if self?.defaults.isInFavourite(id: photo.id) ?? false {
                            photo.isFavorite = true
                        }
                        self?.photos.append(photo)
                    }
                    let newTransportObj = TransportObjectToView(arrOfPhotos: self?.photos ?? [], allPages: self?.allPagesCount ?? 0, loadedPages: self?.pagesLoaded ?? 0)
                    self?.state.value = .successLinks(newTransportObj)
                case let .failure(error):
                    self?.state.value = .error(error)
                }
            })
        } else {
            self.state.value = .error(ApiError(message: "Error in viewModel"))
        }
    }
    func userDefaultsAction(id: String) {
        //        если нажимается кнопка избранного, то по id ищет фото в массиве. если не было в избранном - добавляет, если было - убирает.
        //        обновляет объект самого фото и отправляет массив снова во вью новым стейтом
        defaults.addIdToUD(id: id)
        for photo in photos where photo.id == id {
            if defaults.isInFavourite(id: id) {
                photo.isFavorite = true
            } else {
                photo.isFavorite = false
            }
        }
        let newTransportObj = TransportObjectToView(arrOfPhotos: photos, allPages: allPagesCount, loadedPages: pagesLoaded)
        state.value = .successLinks(newTransportObj)
    }
    func clearForNewSearchQuery() {
        //        убирает всё лишнее, чтобы грузить новые фото с нуля, не продолжая в старую выборку. вызывается если новый запрос отличается от старого
        photos = []
        pagesLoaded = 0
        allPagesCount = 0
        state.value = .loading
    }
}
