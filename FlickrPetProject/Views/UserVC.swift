//
//  UserVC.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//

import UIKit

class UserVC: UIViewController {
// этот класс отвечает за отображение фотографий только одного конретного юзера Flickr. В данном случае - моих. Добавлено для того,
// чтобы приложение не выглядело слишком пустым, чтобы была возможность попереключаться по экранам.

    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = UserViewModel()
    let defaults = UserDefaultsHelper()
    var photos = [FlickrDomainPhoto]()
    var pagesLoaded = 0
    var allPagesCount = 0
    
    var lastState = UserViewModel.UserVMState.loading {
        didSet {
            switch self.lastState {
            default:
                break
//               self.collectionView.reloadData()
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
        self.viewModel.start(loadedPagesFromView: pagesLoaded, availablePages: allPagesCount)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }

    func bindViewModel() {
        //        описание состояний, которые изменяет вьюмодель
        viewModel.state.bind { [weak self] newState in
            guard let self else { return }
            self.lastState = newState
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

extension UserVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.lastState {
        case let .successLinks(objects):
            return objects.arrOfPhotos.count
        default:
            return 0
        }
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
            cell.photoLink = photos[indexPath.row].link
        }
        
//        if photos[indexPath.row].isFavorite {
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

            let imageToShare = [cell.photo.image]
            let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)

        }

        cell.titleLbl.text = photos[indexPath.row].title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width-32, height: self.view.frame.width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newViewController = ShowPhotoVC()
        newViewController.photos = photos
        newViewController.selectedPhoto = indexPath.row
        self.navigationController?.pushViewController(newViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        //        метод для "бесконечного" скролла
        //        стартует вьюмодель как только collectionView подгружает последнюю ячейку
        for index in indexPaths where index.row == photos.count - 1 {
            self.viewModel.start(loadedPagesFromView: pagesLoaded, availablePages: allPagesCount)

        }
//        self.viewModel.needMorePhotos()
    }
}
