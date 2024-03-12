//
//  SearchVC.swift
//  FlickrPetProject
//
//  Created by 8 on 16.12.23.
//

import UIKit

class SearchVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = SearchViewModel()
    let defaults = UserDefaultsHelper()
    var photos = [FlickrDomainPhoto]()
    var pagesLoaded = 0
    var allPagesCount = 0
    var textForSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        отображение строки поиска юзеру
        navigationController?.navigationBar.isHidden = false
    }

    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }

    func bindViewModel() {
        viewModel.state.bind { newState in
            switch newState {
            case let .successLinks(transportObj):
                self.pagesLoaded = transportObj.loadedPages
                self.allPagesCount = transportObj.allPages
                for obj in transportObj.arrOfPhotos {
                    self.photos.append(obj)
                }
                self.collectionView.reloadData()
            case let .error(error):
                self.showAlert(err: error)
            case .loading:
//                self.clearForNewSearchQuery()
                break
            }
        }
    }

    func showAlert(err: Error) {
        let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pagesLoaded == 0 {
            collectionView.setEmptyMessage(Texts.GeneralVCEnum.emptyData)
            return 0
        } else {
            collectionView.setEmptyMessage("")
            return photos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }

        if !photos.isEmpty {
//            если массив фотографий не пуст - ячейке сообщается ссылка на загрузку.
//            как только ссылка будет установлена там сработает didSet, который начнёт загрузку
            cell.photoLink = photos[indexPath.row].link
        }

        if defaults.isInFavourite(id: photos[indexPath.row].id) {
            cell.favouriteBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.favouriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }

        cell.favouritPressed = {
            self.defaults.addIdToUD(id: self.photos[indexPath.row].id)
            self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
        }

        cell.sharePressed = {
            let imageToShare = [ cell.photo.image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }

        cell.titleLbl.text = photos[indexPath.row].title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            //            prefetch используется для бесконечной загрузки фотографий. Как только долистано до предпоследней ячейки в коллекции - снова стартует вьюмодель за новой порцией фотографий
            if index.row == photos.count - 1 {
                self.viewModel.start(loadedPagesFromView: pagesLoaded, availablePages: allPagesCount, searchQuery: textForSearch)

            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newViewController = ShowPhotoVC()
        newViewController.photos = photos
        newViewController.selectedPhoto = indexPath.row
        self.navigationController?.pushViewController(newViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width-32, height: self.view.frame.width)
    }
    
    func clearForNewSearchQuery() {
        //        убирает всё лишнее, чтобы грузить новые фото с нуля, не продолжая в старую выборку. вызывается если новый запрос отличается от старого
        photos = []
        pagesLoaded = 0
        allPagesCount = 0
    }
}
