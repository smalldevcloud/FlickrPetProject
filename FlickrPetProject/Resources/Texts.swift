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
        static var cloud_tab_name: String {  NSLocalizedString("user tab name", comment: "") }
        static var search_tab_name: String { NSLocalizedString("search tab name", comment: "") }
    }
    
    enum SearchVCEnum {
        
    }
    
    enum NetworkerEnum {
//        api key полученный в кабинете разработчика Flickr
        static var apiKey = "811f3fe322aae5677f7eaf0bbd62ecf5"
//        мой user id, нужно для для UserVC, где отображаются только мои фото. Можно заменить на любой другой userID и приложение станет отображать там фото указанного пользователя
        static var userID = "195407962@N05"
//        static var userID = "131351571@N02"
        
        static var format = "json"
//        означает что не нужен callback, на практике даёт то, что ответ приходит в более удобочитаемом формате
        static var noJsonCallback = "1"
        
        static var itemsPerPage = "10"
    }
}
