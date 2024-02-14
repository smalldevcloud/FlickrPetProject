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
    }
    
    func bindViewModel() {
        //        описание состояний, которые изменяет вьюмодель
        viewModel.state.bind{ newState in
            switch newState {
            case .successLinks:
                self.collectionView.reloadData()
            case let .error(error):
                self.showAlert(err: error)
            case .loading:
                break
            }
        }
    }
    
    func showAlert(err: Error) {
        let ac = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
}

extension FavouriteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.photos.count == 0 {
            collectionView.setEmptyMessage(Texts.GeneralVCEnum.empty_data)
            return viewModel.photos.count
        } else {
            collectionView.setEmptyMessage("")
            return viewModel.photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        if !viewModel.photos.isEmpty {
            cell.photoLink = viewModel.photos[indexPath.row].link
        }
        if defaults.isInFavourite(id: viewModel.photos[indexPath.row].id) {
            cell.favouriteBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.favouriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        cell.favouritPressed = {
            self.defaults.addIdToUD(id: self.viewModel.photos[indexPath.row].id)
            self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
        }
        
        cell.sharePressed = {
            let imageToShare = [ cell.photo.image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        cell.titleLbl.text = viewModel.photos[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width-32, height: self.view.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newViewController = ShowPhotoVC()
        newViewController.photos = viewModel.photos
        newViewController.selectedPhoto = indexPath.row
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}
