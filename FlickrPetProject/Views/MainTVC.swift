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
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([
            searchVC,
            userVC], animated: true)
        self.setupUI()
        
    }
    
    func setupUI() {
        self.userVC.tabBarItem.image = UIImage(systemName: "cloud.bolt.rain.fill")
        self.userVC.tabBarItem.title = Texts.TabsEnum.cloud_tab_name
        
        self.searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        self.searchVC.tabBarItem.title = Texts.TabsEnum.search_tab_name
        
        searchBar.delegate = self
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .cyan
        
        navigationItem.titleView  = searchBar
//        searchBar.showsCancelButton = true
//        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchRequest = searchBar.text else { return }
        
        if searchRequest == searchVC.viewModel.textForSearch {
            searchVC.viewModel.start()
        } else {
            searchVC.viewModel.textForSearch = searchRequest
            searchVC.viewModel.clearForNewSearchQuery()
            searchVC.viewModel.start()
        }
        
        
        searchBar.endEditing(true)
    }
    

}
