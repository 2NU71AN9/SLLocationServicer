//
//  FGSearchAddressViewController.swift
//  FBMerchant
//
//  Created by Kevin on 2019/7/1.
//  Copyright © 2019 cn. All rights reserved.
//

import UIKit
import RxSwift
import SLSupportLibrary

class FGSearchAddressViewController: UIViewController {
    
    var selectPoiCallback: ((AMapPOI) -> Void)?
    
    private lazy var searchView: FGSearchHeaderView = {
        let view = FGSearchHeaderView.loadView()
        view.cancelCallback = { [weak self] in
            self?.dismiss()
        }
        return view
    }()
    
    private lazy var search: AMapSearchAPI? = {
        let search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    
    private lazy var request: AMapPOIKeywordsSearchRequest = {
        let request = AMapPOIKeywordsSearchRequest()
        request.requireExtension = true
        request.city = city
//        request.keywords = "北京"
        request.cityLimit = true
        request.requireSubPOIs = true
        return request
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 10
        tableView.estimatedRowHeight = 288.0
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private let bag = DisposeBag()
    private var city: String?
    private var pois: [AMapPOI] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(_ city: String) {
        super.init(nibName: nil, bundle: nil)
        self.city = city
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(searchView)
        view.addSubview(tableView)
        setRx()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.searchTF.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(naviCtrHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FGSearchAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pois.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellid")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellid")
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.textLabel?.numberOfLines = 2
        }
        cell?.textLabel?.text = pois[indexPath.row].addressDesc
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectPoiCallback?(pois[indexPath.row])
        dismiss()
    }
}

// MARK: - AMapSearchDelegate
extension FGSearchAddressViewController: AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
//        if response.count == 0 { return }
        pois = response.pois
    }
}

// MARK: - private methods
extension FGSearchAddressViewController {
    private func dismiss() {
        navigationController?.popViewController(animated: true)
    }
    private func setRx() {
        searchView.searchSubject.subscribe(onNext: { [weak self] (text) in
            self?.search(text)
        }).disposed(by: bag)
    }
    private func search(_ text: String) {
        if text.count == 0 {
            pois = []
            return
        }
        request.keywords = text
        search?.aMapPOIKeywordsSearch(request)
    }
}


extension AMapPOI {
    var addressDesc: String {
        return city + district + address
    }
    var addressDetailDesc: String {
        if province == city { return addressDesc }
        return province + addressDesc
    }
}
