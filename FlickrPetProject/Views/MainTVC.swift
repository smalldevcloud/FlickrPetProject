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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([userVC,
                                 searchVC], animated: true)
        self.setupUI()
    }
    
    func setupUI() {
        self.userVC.tabBarItem.image = UIImage(systemName: "cloud.bolt.rain.fill")
        self.userVC.tabBarItem.title = Texts.TabsEnum.cloud_tab_name
        
        self.searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        self.searchVC.tabBarItem.title = Texts.TabsEnum.search_tab_name
    }

}
