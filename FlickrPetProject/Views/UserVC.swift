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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
        self.viewModel.start()
    }
    
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }
    
    
    
    func bindViewModel() {
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
        print("TODO: finish the error alert")
    }
}

extension UserVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.pagesLoaded == 0 {
            return 0
        } else {
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
        cell.titleLbl.text = viewModel.photos[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 650, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        метод для "бесконечного" скролла
//        стартует вьюмодель как только collectionView подгружает последнюю ячейку
        for index in indexPaths {
            if index.row == viewModel.photos.count - 1 {
                    self.viewModel.start()
            }
        }
    }
}
