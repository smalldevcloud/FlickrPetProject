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

    func start(loadedPagesFromView: Int, availablePages: Int, searchQuery: String) {
        if loadedPagesFromView <= availablePages {
            Networker.shared.searchRequest(searchText: searchQuery, forPage: loadedPagesFromView+1, onResponse: { [weak self] result in
                // нетворкер делает запрос за фотографиями, и в случае успеха объекты преобразуются в более удобные для использования  и сохраняется во вьюмодели
                switch result {
                case let .failure(error):
                    self?.state.value = .error(error)
                case let .success(response):
                    var tempDomainObjects = [FlickrDomainPhoto]()
                    var counter = 0 {
                        didSet {
                            // объекты не передаются дальше, пока для каждого фото из пачки не будет получена ссылка
                            if counter == tempDomainObjects.count {
                                let transportObject = TransportObjectToView(arrOfPhotos: tempDomainObjects, allPages: response.photos.pages, loadedPages: response.photos.page)
                                self?.state.value = .successLinks(transportObject)
                            }
                        }
                    }

                    for item in response.photos.photo {
                        // получение прямых ссылок на картинку для каждого фото. пока все ссылки не будут получены - состояние вью не изменится.
                        // счётчик увеличивается благодаря замыканию, которое срабатывает при успешном получении ссылки. А когда кол-во ссылок
                        // = кол-ву элементов в перебираемом массиве - состояние вью меняется и оно начинает подгружать фото по полученным ссылкам
                        let newPhoto = item.toDomainObject()
                        newPhoto.getLink(completionHandler: { response in
                            if response == true {
                                counter += 1
                            } else {
                                print("==========error============")
                            }
                        })
                        tempDomainObjects.append(newPhoto)
                    }
                }
            })
        } else {
            self.state.value = .error(ApiError(message: "Error in viewModel"))
        }
    }
}
