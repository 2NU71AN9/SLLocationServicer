//
//  SLHotCityCollectionView.swift
//  SLCitySelector
//
//  Created by X.T.X on 2018/3/7.
//  Copyright © 2018年 shiliukeji. All rights reserved.
//

import UIKit
import SnapKit

class SLHotCityCollectionView: UICollectionView {

    /// 选择的城市
    var selectCity: ((String) -> Void)?
    
    var cityArray: [String]? {
        didSet {
            if let cityArray = cityArray {
                frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: CGFloat((cityArray.count + 2) / 3) * 50 + 10)
                reloadData()
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        backgroundColor = UIColor.clear
        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bounces = false
        register(SLHotCityCell.self, forCellWithReuseIdentifier: "hotCoCellid")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SLHotCityCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cityArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotCoCellid", for: indexPath) as? SLHotCityCell
        cell?.textLabel.text = cityArray?[indexPath.row]
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 40)/3, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let city = cityArray?[indexPath.row] {
            selectCity?(city)
        }
    }
}

class SLHotCityCell: UICollectionViewCell {
    
    let textLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.frame = bounds
        textLabel.backgroundColor = UIColor.white
        textLabel.textColor = UIColor.black
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(textLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
