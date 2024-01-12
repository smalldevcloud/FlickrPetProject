//
//  CollectionViewCell.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
//    ячейка коллекции
    static let identifier = "collectionCell"
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var photo: UIImageView!
    let networker = Networker()
    let imageCache = NSCache<AnyObject, AnyObject>.sharedInstance
    private var downloadTask: URLSessionDownloadTask?
    
    
    var photoLink: URL? {
        didSet {
                self.downloadItemImage(imageURL: self.photoLink)

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    func getLink(photoID: String) {
//        networker.getMediumPhoto(photoID: photoID, onResponse: { result in
//            self.photoLink = result
//        })
//    }

    private func downloadItemImage(imageURL: URL?) {
        
            if let urlOfImage = imageURL {
                if let cachedImage = imageCache.object(forKey: urlOfImage.absoluteString as NSString){
                self.photo!.image = cachedImage as? UIImage
                print("cached image was used")
            } else {
                let session = URLSession.shared
                self.downloadTask = session.downloadTask(
                    with: urlOfImage as URL, completionHandler: { [weak self] url, response, error in
                        if error == nil, let url = url, let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {

                            DispatchQueue.main.async() {

                                let imageToCache = image

                                if let strongSelf = self, let imageView = strongSelf.photo {
                                    print("image downloaded")
                                    imageView.image = imageToCache

                                    self!.imageCache.setObject(imageToCache, forKey: urlOfImage.absoluteString as NSString , cost: 1)
                                }
                            }
                        } else {
                            //print("ERROR \(error?.localizedDescription)")
                        }
                })
                self.downloadTask!.resume()
            }
          }
        }
    
    override public func prepareForReuse() {
      self.downloadTask?.cancel()
      photo.image = UIImage(systemName: "gear")
    }

    deinit {
      self.downloadTask?.cancel()
      photo.image = nil
    }
}
