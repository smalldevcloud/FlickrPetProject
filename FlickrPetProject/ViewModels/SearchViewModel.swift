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

    func start(loadedPagesFromView: Int, availablePages: Int, searchQuery: String) {
        if loadedPagesFromView <= availablePages {
            flickrWorker.getPhotos(text: searchQuery, forPage: loadedPagesFromView, onResponse: { [weak self] result in
                switch result {
                case let .success(transportObj):
                    self?.state.value = .successLinks(transportObj)
                case let .failure(error):
                    self?.state.value = .error(error)
                }
            })
        } else {
            self.state.value = .error(ApiError(message: "Error in viewModel"))
        }
    }
}
