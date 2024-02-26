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
        userVC.tabBarItem.title = Texts.TabsEnum.cloudTabName

        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchVC.tabBarItem.title = Texts.TabsEnum.searchTabName

        favouriteVC.tabBarItem.image = UIImage(systemName: "star")
        favouriteVC.tabBarItem.title = Texts.TabsEnum.favouriteTabName

        searchBar.delegate = self

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .cyan

        searchBar.showsCancelButton = true

        navigationItem.titleView  = searchBar
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchRequest = searchBar.text else { return }
        //        если текст тот же, что был до этого - просто запуск вьюмодели. Если текст другой - то перед запуском обнуление загруженных страницы и указание нового текста для поиска
        if searchRequest == searchVC.textForSearch {
            searchVC.viewModel.start(loadedPagesFromView: searchVC.pagesLoaded, availablePages: searchVC.allPagesCount, searchQuery: searchVC.textForSearch)
        } else {
            searchVC.textForSearch = searchRequest
            searchVC.clearForNewSearchQuery()
            searchVC.viewModel.start(loadedPagesFromView: searchVC.pagesLoaded, availablePages: searchVC.allPagesCount, searchQuery: searchVC.textForSearch)
        }

        searchBar.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //        прячет клавиатуру по нажатию "cancel" в searchBar
        searchBar.endEditing(true)
    }
}
