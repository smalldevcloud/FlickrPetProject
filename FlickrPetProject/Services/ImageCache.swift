//
//  ImageCache.swift
//  FlickrPetProject
//
//  Created by 8 on 12.01.24.
//

import Foundation

final class ImageCache {
//    синглтон для кэширования изображений
    @objc static var shared: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        cache.countLimit = 10
//        лимит кэширования. если не выставить - прилага сожрёт гиг памяти
        return cache
    }()
}
