//
//  ViewController.swift
//  SLLocationServicer
//
//  Created by 孙梁 on 2020/11/25.
//

import UIKit
import AMapFoundationKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 先注册高德地图key
        let vc = FGMapChooseAddressViewController.makeVC { (_) in
            
        }
        present(vc, animated: true, completion: nil)
    }
}

