//
//  SLCitySelectorViewController.swift
//  SLCitySelector
//
//  Created by X.T.X on 2018/3/7.
//  Copyright © 2018年 shiliukeji. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

let backColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)

class SLCitySelectorViewController: UIViewController {
    
    let selectCitySubject = PublishSubject<String>()
    
    /// 选择的城市
    var selectCity: String? {
        didSet {
            if let selectCity = selectCity {
                selectCitySubject.onNext(selectCity)
                selectCitySubject.onCompleted()
            }
        }
    }
    
    //城市列表
    private lazy var tableView: SLCitySelectorView = {
        let tableView = SLCitySelectorView(frame: UIScreen.main.bounds, style: .plain)
        tableView.cityDic = cityDic
        tableView.hotCities = hotCities
        tableView.titleArray = titleArray
        tableView.reloadData()
        tableView.selectCity = { [weak self] city in
            self?.selectCity = city
            self?.dissmiss()
        }
        return tableView
    }()
    //搜索结果控制器
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchVC)
        searchVC.cityDic = cityDic
        searchController.searchResultsUpdater = searchVC
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .minimal
        return searchController
    }()
    private lazy var searchVC: SLCitySelectorSearchViewController = {
        let sv = SLCitySelectorSearchViewController()
        sv.selectCity = { [weak self] city in
            self?.selectCity = city
            self?.dissmiss()
        }
        return sv
    }()
    //获取城市数据
    lazy var cityDic:[String:[String]] = {
        let path = Bundle.main.path(forResource: "cities", ofType: "plist")
        let dic = NSDictionary(contentsOfFile: path!)
        return dic as! [String : [String]]
    }()
    //热门城市
    lazy var hotCities:[String] = {
        let path = Bundle.main.path(forResource: "hotCities", ofType: "plist")
        let array = NSDictionary(contentsOfFile: path!)?.value(forKey: "Hot")
        return array as! [String]
    }()
    //标题数组
    lazy var titleArray:[String] = {
        var array = [String]()
        for str in self.cityDic.keys {
            array.append(str)
        }
        array.sort()
        array.insert("热门", at: 0)
        array.insert("定位", at: 0)
        return array
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择城市"
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navi_back_black"), style: .plain, target: self, action: #selector(dissmiss))
        
        view.addSubview(tableView)
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        // 这句一定要加
        definesPresentationContext = true
        
        startLocation()
    }
}
extension SLCitySelectorViewController: UISearchBarDelegate, UISearchControllerDelegate {

}

extension SLCitySelectorViewController {
    @objc private func dissmiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func startLocation() {
        LocationService.turnOn()
    }
}
