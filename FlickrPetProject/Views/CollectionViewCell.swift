//
//  CollectionViewCell.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    static let identifier = "collectionCell"
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!

    private var downloadTask: URLSessionDownloadTask?
    var favouritPressed: (() -> Void ) = {}
    var sharePressed: (() -> Void ) = {}

    var photoLink: URL? {
        didSet {
            // как только ссылка на фото установлена - качается фото
            self.downloadItemImage(imageURL: self.photoLink)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.actIndicator.isHidden = false
        self.actIndicator.startAnimating()
    }

    private func downloadItemImage(imageURL: URL?) {
        //        скачивание фото по ссылке
        if let urlOfImage = imageURL {
            //          ссылка также используется как ключ для сохранения в кэш. И если в кэш уже сохранено, то картинка берётся оттуда, вместо повторной загрузки
            if let cachedImage = ImageCache.shared.object(forKey: urlOfImage.absoluteString as NSString){
                self.photo!.image = cachedImage as? UIImage
                self.actIndicator.isHidden = true
                self.actIndicator.stopAnimating()
            } else {
                //                если в кэше не нашлось - загрузка
                let session = URLSession.shared
                self.downloadTask = session.downloadTask(
                    with: urlOfImage as URL, completionHandler: { [weak self] url, response, error in
                        if error == nil, let url = url, let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {
                            DispatchQueue.main.async {
                                let imageToCache = image
                                if let strongSelf = self, let imageView = strongSelf.photo {
                                    imageView.image = imageToCache
                                    // после отображения картинки - сохранение в кэш
                                    ImageCache.shared.setObject(imageToCache, forKey: urlOfImage.absoluteString as NSString, cost: 1)
                                    self?.actIndicator.isHidden = true
                                    self?.actIndicator.stopAnimating()
                                }
                            }
                        } else {
                            print("can't download img: \(error?.localizedDescription)")
                        }
                    })
                self.downloadTask!.resume()
            }
        }
    }

    override public func prepareForReuse() {
        //        при переиспользовании использовании ячейки, пока картинка качается или достаётся из кэша можно использовать что-нибудь красивое,
        //        картинку-плейсхолдер которую заменит загруженный файл. я использую не очень красивую картинку шестерёнки
        self.downloadTask?.cancel()
        actIndicator.isHidden = false
        actIndicator.startAnimating()
        photo.image = nil
    }

    @IBAction func favoriteIcon(_ sender: Any) {
        favouritPressed()
    }

    @IBAction func shareBtnTapped(_ sender: Any) {
        sharePressed()
    }

    deinit {
        //    отмена загрузки, если объект уничножается
        self.downloadTask?.cancel()
        photo.image = nil
    }
}
