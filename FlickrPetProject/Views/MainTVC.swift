//
//  MainTVC.swift
//  FlickrPetProject
//
//  Created by 8 on 16.12.23.
//
import UIKit
class MainTVC: UITabBarController, UISearchBarDelegate {
//    этот класс необходим для реализации TabBar'a (переключение вьюконтроллеров по нажатию иконок снизу экрана)
    let userVC = UserVC()
    let searchVC = SearchVC()
    let favouriteVC = FavouriteVC()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([
            userVC,
            searchVC,
            favouriteVC
            ], animated: true)
        self.setupUI()
        
    }
    
    func setupUI() {
        userVC.tabBarItem.image = UIImage(systemName: "cloud.bolt.rain.fill")
        userVC.tabBarItem.title = Texts.TabsEnum.cloud_tab_name
        
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchVC.tabBarItem.title = Texts.TabsEnum.search_tab_name
        
        favouriteVC.tabBarItem.image = UIImage(systemName: "star")
        favouriteVC.tabBarItem.title = Texts.TabsEnum.favourite_tab_name
        
        searchBar.delegate = self
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .cyan
        
        searchBar.showsCancelButton = true
        
        navigationItem.titleView  = searchBar
//        searchBar.becomeFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchRequest = searchBar.text else { return }
//        если текст тот же, что был до этого - просто запуск вьюмодели. Если текст другой - то перед запуском обнуление загруженных страницы и указание нового текста для поиска
        if searchRequest == searchVC.viewModel.textForSearch {
            searchVC.viewModel.start()
        } else {
            searchVC.viewModel.textForSearch = searchRequest
            searchVC.viewModel.clearForNewSearchQuery()
            searchVC.viewModel.start()
        }
        
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        прячет клавиатуру по нажатию "cancel" в searchBar
        searchBar.endEditing(true)
    }
}
