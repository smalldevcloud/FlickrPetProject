//
//  FavouriteVC.swift
//  FlickrPetProject
//
//  Created by 8 on 29.01.24.
//

import UIKit

class FavouriteVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = FavouritsViewModel()
    let defaults = UserDefaultsHelper()
    var photos = [FlickrDomainPhoto]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
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
        viewModel.state.bind { newState in
            switch newState {
            case let .successLinks(transportObj):
                for obj in transportObj.arrOfPhotos {
                    self.photos.append(obj)
                }
                self.collectionView.reloadData()
            case let .error(error):
                self.showAlert(err: error)
            case .loading:
//                break
                self.photos.removeAll()
            }
        }
    }

    func showAlert(err: Error) {
        let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}

extension FavouriteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photos.count == 0 {
            collectionView.setEmptyMessage(Texts.GeneralVCEnum.emptyData)
            return photos.count
        } else {
            collectionView.setEmptyMessage("")
            return photos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.identifier,
            for: indexPath
        ) as? CollectionViewCell else { return UICollectionViewCell() }

        if !photos.isEmpty {
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width-32, height: self.view.frame.width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newViewController = ShowPhotoVC()
        newViewController.photos = photos
        newViewController.selectedPhoto = indexPath.row
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}
