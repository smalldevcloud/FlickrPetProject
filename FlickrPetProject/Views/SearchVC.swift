//
//  SearchVC.swift
//  FlickrPetProject
//
//  Created by 8 on 16.12.23.
//

import UIKit

class SearchVC: UIViewController, UISearchBarDelegate {
// этот класс отвечает за отображение фотографий по поисковому запросу
    
    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = SearchViewModel()
    let searchBar = UISearchBar()
    var textForSearch = ""
    var lastState = SearchViewModel.SearchVMState.loading {
        didSet {
            switch self.lastState {
            case .successLinks:
                print("new state loaded")
               self.collectionView.reloadData()
            default:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
    }

    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .cyan

        searchBar.showsCancelButton = true
        navigationItem.titleView  = searchBar
        searchBar.delegate = self
    }

    func bindViewModel() {
        viewModel.state.bind { [weak self] newState in
            guard let self else { return }
            self.lastState = newState
            switch newState {
            case let .successLinks(transportObj):
                lastState = SearchViewModel.SearchVMState.successLinks(transportObj)
            case let .error(error):
                self.showAlert(err: error)
            case .loading:
                break
            }
        }
    }

    func showAlert(err: Error) {
        let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    func sharePhoto(img: UIImage) {
        let imageToShare = [img]
        let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }

    func favoutireAction(photoId: String, cellNumber: Int) {
        self.viewModel.userDefaultsAction(id: photoId)
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.lastState {
        case let .successLinks(objects):
            return objects.arrOfPhotos.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell()
        }
        switch lastState {
        case let.successLinks(stateObject):
            if !stateObject.arrOfPhotos.isEmpty {
                cell.photoLink = stateObject.arrOfPhotos[indexPath.row].link
            }
            if stateObject.arrOfPhotos[indexPath.row].isFavorite {
                cell.favouriteBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                cell.favouriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
            }
            cell.favouritPressed = {
                self.favoutireAction(photoId: stateObject.arrOfPhotos[indexPath.row].id, cellNumber: indexPath.row)
            }
            cell.sharePressed = {
                guard let img = cell.photo.image else { return }
                self.sharePhoto(img: img)
            }
            cell.titleLbl.text = stateObject.arrOfPhotos[indexPath.row].title
            return cell
        case .loading:
            return UICollectionViewCell()
        case .error:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        switch lastState {
        case let.successLinks(stateObject):
            for index in indexPaths where index.row == stateObject.arrOfPhotos.count - 1 {
                self.viewModel.start(searchQuery: textForSearch)
            }
        case .loading:
            break
        case .error(_):
            break
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newViewController = ShowPhotoVC()
        switch lastState {
        case let.successLinks(stateObject):
            newViewController.photos = stateObject.arrOfPhotos
            newViewController.selectedPhoto = indexPath.row
            self.present(newViewController, animated: true)
//            newNavController.pushViewController(newViewController, animated: true)
        case .loading:
            break
        case .error(_):
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width-32, height: self.view.frame.width)
    }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let searchRequest = searchBar.text else { return }
            //        если текст тот же, что был до этого - просто запуск вьюмодели. Если текст другой - то перед запуском обнуление загруженных страницы и указание нового текста для поиска
            if searchRequest == textForSearch {
                viewModel.start(searchQuery: textForSearch)
            } else {
                textForSearch = searchRequest
                viewModel.clearForNewSearchQuery()
                viewModel.start(searchQuery: textForSearch)
            }
            searchBar.endEditing(true)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            //        прячет клавиатуру по нажатию "cancel" в searchBar
            searchBar.endEditing(true)
        }
}
