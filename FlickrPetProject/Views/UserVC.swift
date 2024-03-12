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
    var lastState = UserViewModel.UserVMState.loading {
        didSet {
            switch self.lastState {
            default:
               self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
        self.viewModel.start()
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
                lastState = UserViewModel.UserVMState.successLinks(transportObj)
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
        self.defaults.addIdToUD(id: photoId)
        self.collectionView.reloadItems(at: [IndexPath(row: cellNumber, section: 0)])
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
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        switch lastState {
        case let.successLinks(stateObject):
            if !stateObject.arrOfPhotos.isEmpty {
                cell.photoLink = stateObject.arrOfPhotos[indexPath.row].link
            }
            if defaults.isInFavourite(id: stateObject.arrOfPhotos[indexPath.row].id) {
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
        case .error(_):
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width-32, height: self.view.frame.width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newViewController = ShowPhotoVC()
        switch lastState {
        case let.successLinks(stateObject):
            newViewController.photos = stateObject.arrOfPhotos
            newViewController.selectedPhoto = indexPath.row
            self.navigationController?.pushViewController(newViewController, animated: true)
        case .loading:
            break
        case .error(_):
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        //        метод для "бесконечного" скролла
        //        стартует вьюмодель как только collectionView подгружает последнюю ячейку
        switch lastState {
        case let.successLinks(stateObject):
            for index in indexPaths where index.row == stateObject.arrOfPhotos.count - 1 {
                self.viewModel.start()
            }
        case .loading:
            break
        case .error(_):
            break
        }
    }
}
