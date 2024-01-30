//
//  UserDefaultsHelper.swift
//  FlickrPetProject
//
//  Created by 8 on 25.01.24.
//

import Foundation
final class UserDefaultsHelper {
//    чтобы избранные фото сохранялись при перезапуске приложения, они сохраняются в userDefaults в виде массива строк из id

    
    let ud = UserDefaults.standard
    var array: [String] = []
    
    func addIdToUD(id: String) {
//        добавляет фото в избранное
        getIds()
        
        if array.contains(id) {
            print("already contain. need to remove")
            guard let index = array.firstIndex(of: id) else { return }
            array.remove(at: index)
            
        } else {
            array.append(id)
            print("new arr inserted")
        }
        setIds(ids: array)
        print(array)
    }
    
    func isInFavourite(id: String) -> Bool {
//        проверяет, добавлено ли фото в избранное
        getIds()
        
        if array.contains(id) {
            return true
        } else {
            return false
        }
    }
    
    func getIds(){
//        обновляет данные по избранным обращаясь к userDefaults
        guard let ids = ud.object(forKey: Texts.UserDefaultsEnum.favouritsArrKey) as? [String] else { return }
        array = ids

    }
    
    private func setIds(ids: [String]) {
//        внутренняя функция сохранения в UD
        ud.setValue(ids, forKey: Texts.UserDefaultsEnum.favouritsArrKey)
    }
    
}
