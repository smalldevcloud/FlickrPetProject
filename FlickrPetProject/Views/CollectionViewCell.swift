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
    var updateHandler: (() -> ())!
    var photoLink: URL? {
        didSet {
            networker.downloadPhoto(from: photoLink!, onResponse: { result in
                self.photo.image = UIImage(data: result)
//                self.updateHandler()
            })
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getLink(photoID: String) {
        networker.getMediumPhoto(photoID: photoID, onResponse: { result in
            self.photoLink = result
        })
    }

//    init?(titleLbl: UILabel!, photo: UIImageView!, photoLink: URL, frame: CGRect) {
//        self.titleLbl = titleLbl
//        self.photo = photo
//        self.photoLink = photoLink
//        super.init(frame: frame)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
}
