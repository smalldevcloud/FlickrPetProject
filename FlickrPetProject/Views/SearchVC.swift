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
    }
    
    func bindViewModel() {
        viewModel.state.bind{ newState in
            switch newState {
            case .successPhotos:
                self.collectionView.reloadData()
            case let .error(error):
                print(error.localizedDescription)
            case .loading:
                print("loading")
            }
            
        }
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
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
//            если массив фотографий не пуст - ячейке сообщается ссылка на загрузку. как только ссылка будет установлена там сработает didSet, который начнёт загрузку
            cell.photoLink = viewModel.photos[indexPath.row].link
        }
        cell.titleLbl.text = viewModel.photos[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
//            prefetch используется для бесконечной загрузки фотографий. Как только долистано до предпоследней ячейки в коллекции - снова стартует вьюмодель за новой порцией фотографий
            if index.row == viewModel.photos.count - 1 {
                self.viewModel.start()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newViewController = ShowPhotoVC()
        newViewController.photos = viewModel.photos
        newViewController.selectedPhoto = indexPath.row
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 650, height: 250)
    }
}
