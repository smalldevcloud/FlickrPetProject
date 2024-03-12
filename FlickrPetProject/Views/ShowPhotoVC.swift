//
//  ShowPhotoVC.swift
//  FlickrPetProject
//
//  Created by 8 on 21.01.24.
//

import UIKit

class ShowPhotoVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var photos = [FlickrDomainPhoto]()
    var selectedPhoto = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        отображение строки поиска юзеру
        navigationController?.navigationBar.isHidden = false
    }

    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollToItem(
            at: IndexPath(item: selectedPhoto, section: 0),
            at: .right,
            animated: false
        )
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let collectionView = collectionView else { return }
        flowLayout.itemSize = collectionView.bounds.size
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
}

extension ShowPhotoVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        if !photos.isEmpty {
            //            если массив фотографий не пуст - ячейке сообщается ссылка на загрузку. как только ссылка будет установлена там сработает didSet, который начнёт загрузку
            cell.photoLink = photos[indexPath.row].link
        }
        cell.titleLbl.text = photos[indexPath.row].title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        return screenSize
        }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        отвечает за то, чтобы при скролле не появлялось смещение фотографий
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let pageWidth = scrollView.bounds.size.width + flowLayout.minimumInteritemSpacing
        let currentPageNumber = round(scrollView.contentOffset.x / pageWidth)
        let maxPageNumber = CGFloat(collectionView?.numberOfItems(inSection: 0) ?? 0)
        var pageNumber = round(targetContentOffset.pointee.x / pageWidth)
        pageNumber = max(0, currentPageNumber - 1, pageNumber)
        pageNumber = min(maxPageNumber, currentPageNumber + 1, pageNumber)
        targetContentOffset.pointee.x = pageNumber * pageWidth
    }
}
