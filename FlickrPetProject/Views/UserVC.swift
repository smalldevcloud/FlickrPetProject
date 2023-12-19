//
//  UserVC.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//

import UIKit

class UserVC: UIViewController {
// этот класс отвечает за отображение фотографий только одного конретного юзера Flickr. В данном случае - моих. Добавлено для того, чтобы приложение не выглядело слишком пустым, чтобы была возможность попереключаться по экранам.

    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = UserViewModel()
    var photos: [FlickrPhoto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
        self.viewModel.start()
        
    }
    
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func bindViewModel() {
        viewModel.state.bind{ newState in
            switch newState {
            case let .success(photosResponse):
                self.photos = photosResponse.photos.photo
                self.collectionView.reloadData()
            case let .error(error):
                self.showAlert(err: error)
            case .loading:
                break
            }
        }
    }
    
    func showAlert(err: Error) {
        
    }
    

}

extension UserVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        cell.getLink(photoID: photos[indexPath.row].id)
//        cell.updateHandler = {
//            self.collectionView.reloadData()
//            print("update happend")
//        }
        cell.titleLbl.text = photos[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 650, height: 250)
        }
    
    
}
