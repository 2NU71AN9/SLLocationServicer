//
//  SLCitySelectorSearchViewController.swift
//  SLCitySelector
//
//  Created by X.T.X on 2018/3/7.
//  Copyright © 2018年 shiliukeji. All rights reserved.
//

import UIKit

class SLCitySelectorSearchViewController: UIViewController {

    /// 选择的城市
    var selectCity: ((String) -> Void)?
    
    //城市数据
    var cityDic:[String:[String]] = [:]
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    //搜索结果
    var resultArray: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 42
    }
    
    /// 搜索
    func getSearchResultArray(_ text: String) {
        
        var array:[String] = []
        
        // FIXME: - sl_isChinese此方法不完善
        if text.sl_isChinese {
            // 中文搜索
            // 转拼音
            let pinyin = text.sl_chinese2PinYin()
            // 获取大写首字母
            let first = String(pinyin[pinyin.startIndex]).uppercased()
            guard let dic = cityDic[first] else {
                resultArray = []
                return
            }
            for str in dic {
                if str.hasPrefix(text) {
                    array.append(str)
                }
            }
            resultArray = array
        } else {
            // 拼音搜索
            // 若字符个数为1
            if text.count == 1 {
                guard let dic = cityDic[text.uppercased()] else {
                    resultArray = []
                    return
                }
                array = dic
                resultArray = array
            } else {
                // 若字符个数>1
                guard let dic = cityDic[text.prefix(1).uppercased()] else {
                    resultArray = []
                    return
                }
                for str in dic {
                    let py = str.sl_chinese2PinYin().uppercased()
                    let range = py.range(of: text.uppercased())
                    if range != nil {
                        array.append(str)
                    }
                }
                resultArray = array
            }
        }
    }
}

extension SLCitySelectorSearchViewController: UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    //每输入一个字符都会执行一次
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            if text.count > 0 {
                getSearchResultArray(text)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellid")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cellid")
            cell?.selectionStyle = .none
            cell?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        cell?.textLabel?.text = resultArray[indexPath.section]
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCity?(resultArray[indexPath.section])
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        IQKeyboardManager.shared.resignFirstResponder()
    }
}
