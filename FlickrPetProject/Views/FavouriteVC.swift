//
//  FavouriteVC.swift
//  FlickrPetProject
//
//  Created by 8 on 29.01.24.
//

import UIKit

class FavouriteVC: UIViewController {
// этот класс отвечает за отображение избранных фотографий
    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = FavouritsViewModel()
    var lastState = FavouritsViewModel.FavouritsVMState.loading {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.start()
    }

    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }

    func bindViewModel() {
        //        описание состояний, которые изменяет вьюмодель
        viewModel.state.bind { [weak self] newState in
            switch newState {
            case let .successLinks(transportObj):
                self?.lastState = FavouritsViewModel.FavouritsVMState.successLinks(transportObj)
            case let .error(error):
                self?.showAlert(err: error)
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

extension FavouriteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.lastState {
        case let .successLinks(objects):
            if objects.arrOfPhotos.count == 0 {
                collectionView.setEmptyMessage(Texts.GeneralVCEnum.emptyData)
            }
            return objects.arrOfPhotos.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.identifier,
            for: indexPath
        ) as? CollectionViewCell else { return UICollectionViewCell() }

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
        return cell
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
            self.present(newViewController, animated: true)
//            newNavController.pushViewController(newViewController, animated: true)
        case .loading:
            break
        case .error(_):
            break
        }
    }
}
