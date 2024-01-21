//
//  Model.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//
import Foundation

//enum который будет использоваться для указания метода при формировании url запроса
enum FlickrAPIMetod: String {
    case Photos = "flickr.people.getPhotos"
    case GetSizes = "flickr.photos.getSizes"
    case Search = "flickr.photos.search"
}

//модель, описывающая ответ который придёт при запросе на получение фото (конкретного пользователя, либо по поисковому запросу)
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

//модель для более удобной работы с фотографиями
class FlickrDomainPhoto {
    var id: String = ""
    var title: String = ""
    var link: URL?
    
    func getLink(completionHandler: @escaping (Bool) -> Void) {
        Networker.shared.getMediumSizeLinks(photoID: id, onResponse: { result in
            self.link = result
            completionHandler(true)
        })
    }
}

//модель, описывающая размеры изображений
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

// енам с возможными массивами для быстрого доступа к значению
enum SizeLables: String, Decodable {
    case Square = "Square"
    case LargeSquare = "Large Square"
    case Thumbnail = "Thumbnail"
    case Small = "Small"
    case Small320 = "Small 320"
    case Small400 = "Small 400"
    case Medium = "Medium"
    case Medium640 = "Medium 640"
    case Medium800 = "Medium 800"
    case Large = "Large"
    case Large1600 = "Large 1600"
    case Large2048 = "Large 2048"
    case XLarge3K = "X-Large 3K"
    case XLarge4K = "X-Large 4K"
    case XLarge5K = "X-Large 5K"
    case XLarge6K = "X-Large 6K"
    case Original = "Original"

}

// собственная ошибка для удобства отображения пользователю
struct ApiError: Error, LocalizedError {
    let message: String
    
    var errorDescription: String? {
        return self.message
    }
}
