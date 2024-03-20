//
//  MainTVC.swift
//  FlickrPetProject
//
//  Created by 8 on 16.12.23.
//
import UIKit
class MainTVC: UITabBarController {
    //    этот класс необходим для реализации TabBar'a (переключение вьюконтроллеров по нажатию иконок снизу экрана)
    let userVC = UserVC()
    let searchVC = SearchVC()
    let navigationSearchVC = UINavigationController(rootViewController: SearchVC())
    let favouriteVC = FavouriteVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([
            userVC,
            navigationSearchVC,
            favouriteVC
        ], animated: true)
        self.setupUI()
    }

    func setupUI() {
        userVC.tabBarItem.image = UIImage(systemName: "cloud.bolt.rain.fill")
        userVC.tabBarItem.title = Texts.TabsEnum.cloudTabName
        navigationSearchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        navigationSearchVC.tabBarItem.title = Texts.TabsEnum.searchTabName
        favouriteVC.tabBarItem.image = UIImage(systemName: "star")
        favouriteVC.tabBarItem.title = Texts.TabsEnum.favouriteTabName
    }
}
