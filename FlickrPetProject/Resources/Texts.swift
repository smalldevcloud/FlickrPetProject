//
//  Texts.swift
//  FlickrPetProject
//
//  Created by 8 on 16.12.23.
//

import Foundation

enum Texts {
    //    енам с енамами для локализации строк
    //    ru и en локали

    enum TabsEnum {
        static var cloudTabName: String {  NSLocalizedString("user tab name", comment: "") }
        static var searchTabName: String { NSLocalizedString("search tab name", comment: "") }
        static var favouriteTabName: String { NSLocalizedString("favourite tab name", comment: "") }
    }

    enum GeneralVCEnum {
        static var emptyData: String { NSLocalizedString("empty data", comment: "") }
    }

    enum UserDefaultsEnum {
        static var favouritsArrKey = "favourits"
    }

    enum NetworkerEnum {
        //        api key полученный в кабинете разработчика Flickr. Да, не секьюрно оставлять его в гитхабе в общем доступе, но так вы без проблем сможете запустить прилагу,
//        а сам ключ если что я в лбой момент могу заблокировать в аккаунте flickr 
        static var apiKey = "29903d5c2e9a5dca170153b5de01a648"
        //        мой user id, нужно для для UserVC, где отображаются только мои фото. Можно заменить на любой другой userID и приложение станет отображать там фото указанного пользователя
        static var userID = "195407962@N05"
        //        static var userID = "131351571@N02"

        static var format = "json"
        //        означает что не нужен callback, на практике даёт то, что ответ приходит в более удобочитаемом формате
        static var noJsonCallback = "1"

        static var itemsPerPage = "10"
    }
}
