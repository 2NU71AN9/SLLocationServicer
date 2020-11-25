//
//  FGChoosCitySearchView.swift
//  FBMerchant
//
//  Created by Kevin on 2019/7/1.
//  Copyright © 2019 cn. All rights reserved.
//

import UIKit
import RxSwift

class FGChoosCitySearchView: UIView {

    var chooseCityCallback: (() -> Void)?
    var chooseAddressCallback: (() -> Void)?
    
    var city: String? {
        didSet {
            chooseCityBtn.setTitle(city, for: .normal)
        }
    }
    
    let bag = DisposeBag()
    
    @IBOutlet weak var chooseCityBtn: UIButton!
    @IBOutlet weak var searchView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(searchAction))
            searchView.addGestureRecognizer(tap)
        }
    }
    
    @IBAction func chooseCityAction(_ sender: Any) {
        chooseCityCallback?()
    }
    
    @objc private func searchAction() {
        chooseAddressCallback?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    static func loadView() -> FGChoosCitySearchView {
        guard let view = Bundle.main.loadNibNamed("FGChoosCitySearchView", owner: self, options: nil)?.last as? FGChoosCitySearchView else {
            return FGChoosCitySearchView()
        }
        return view
    }
}
