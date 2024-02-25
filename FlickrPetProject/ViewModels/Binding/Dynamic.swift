//
//  Dynamic.swift
//  FlickrPetProject
//
//  Created by 8 on 19.12.23.
//
import Foundation

class Dynamic<Generic> {
//    класс, с помощью которого будут связаны viewModel и view. В роли value всегда будет выступать state - состояние (ожидание, загрузка, ошибка и т.д)
//    value является дженериком, т.к. к каждому состоянию будет прикреплён свой тип передаваемых данных (например если успешно загрузился список фотографий - 
//    то массив с фотографиями или ошибка, тогда передаваться должна ошибка. Используя дженерик можно добиться большей гибкости в передаче состояний
    var value: Generic {
        didSet {
            DispatchQueue.main.async {
//                как только value было установлено - оно добавляется всем слушателям
                for listener in self.listeners {
                    listener(self.value)
                }
            }
        }
    }

    init(_ value: Generic) {
        self.value = value
    }

    private var listeners = [(Generic) -> Void]()

    func bind(_ listener: @escaping (Generic) -> Void) {
//        функция, которую нужно вызвать для привязки
        listener(value)
        self.listeners.append(listener)
    }
}
