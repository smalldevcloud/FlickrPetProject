//
//  Model.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//
import Foundation
import UIKit

// enum который будет использоваться для указания метода при формировании url запроса
enum FlickrAPIMetod: String {
    case photos = "flickr.people.getPhotos"
    case getSizes = "flickr.photos.getSizes"
    case search = "flickr.photos.search"
}

// модель, описывающая ответ который придёт при запросе на получение фото (конкретного пользователя, либо по поисковому запросу)
struct FlickrJSONResponse: Decodable {
    let photos: FlickrPhotos
    let stat: String?
}
// MARK: - Photos
struct FlickrPhotos: Decodable {
    let page, pages, perpage, total: Int
    let photo: [FlickrPhoto]
}
// MARK: - Photo
struct FlickrPhoto: Decodable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int

    func toDomainObject() -> FlickrDomainPhoto {
        let domainPhoto = FlickrDomainPhoto()
        domainPhoto.id = id
        domainPhoto.title = title
        return domainPhoto
    }
}

// модель для более удобной работы с фотографиями
class FlickrDomainPhoto {
    var id: String = ""
    var title: String = ""
    var link: URL?
    var isFavorite: Bool = false

    func getLink(completionHandler: @escaping (Bool) -> Void) {
        Networker.shared.getMediumSizeLinks(photoID: id, onResponse: { result in
            switch result {
            case let .success(url):
                self.link = url
                completionHandler(true)
            case let .failure(error):
                completionHandler(false)
                print(error.localizedDescription)
            }
        })
    }
}

// модель, описывающая размеры изображений
struct FlickrSizesResponse: Decodable {
    let sizes: Sizes
    let stat: String
}

struct Sizes: Decodable {
    let canblog, canprint, candownload: Int
    let size: [Size]
}

struct Size: Decodable {
    let label: SizeLables
    let width, height: Int
    let source: String
    let url: String
    let media: String
}

// енам с возможными размерами для быстрого доступа к значению
enum SizeLables: String, Decodable {
    case square = "Square"
    case largeSquare = "Large Square"
    case thumbnail = "Thumbnail"
    case small = "Small"
    case small320 = "Small 320"
    case small400 = "Small 400"
    case medium = "Medium"
    case medium640 = "Medium 640"
    case medium800 = "Medium 800"
    case large = "Large"
    case large1600 = "Large 1600"
    case large2048 = "Large 2048"
    case xLarge3K = "X-Large 3K"
    case xLarge4K = "X-Large 4K"
    case xLarge5K = "X-Large 5K"
    case xLarge6K = "X-Large 6K"
    case original = "Original"

}

// собственная ошибка для удобства отображения пользователю
struct ApiError: Error, LocalizedError {
    let message: String

    var errorDescription: String? {
        return self.message
    }
}

public class CollectionViewFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
