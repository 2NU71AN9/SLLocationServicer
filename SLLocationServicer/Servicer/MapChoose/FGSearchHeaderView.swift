//
//  FGSearchHeaderView.swift
//  FBMerchant
//
//  Created by Kevin on 2019/7/1.
//  Copyright © 2019 cn. All rights reserved.
//

import UIKit
import RxSwift
import SLSupportLibrary

class FGSearchHeaderView: UIView {

    let searchSubject = PublishSubject<String>()
    var cancelCallback: (() -> Void)?

    private let bag = DisposeBag()
    @IBOutlet weak var searchTF: UITextField! {
        didSet {
            searchTF.rx.text.orEmpty
                .distinctUntilChanged()
                .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
                .bind(to: searchSubject)
                .disposed(by: bag)
        }
    }
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelAction(_ sender: Any) {
        cancelCallback?()
    }
    
    static func loadView() -> FGSearchHeaderView {
        guard let view = Bundle.main.loadNibNamed("FGSearchHeaderView", owner: self, options: nil)?.last as? FGSearchHeaderView else {
            return FGSearchHeaderView()
        }
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: naviCtrHeight)
        return view
    }
}
