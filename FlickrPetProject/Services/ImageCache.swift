//
//  ImageCache.swift
//  FlickrPetProject
//
//  Created by 8 on 12.01.24.
//

import Foundation

class ImageCache {
//    синглтон для кэширования изображений
    @objc static var shared: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        return cache
    }()
}
