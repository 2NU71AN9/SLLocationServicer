//
//  FGChooseAddressswift
//  FBMerchant
//
//  Created by Kevin on 2019/7/2.
//  Copyright © 2019 cn. All rights reserved.
//

import UIKit
import SLSupportLibrary

let tableShow_Y: CGFloat = SCREEN_HEIGHT/2
let tableHide_Y: CGFloat = SCREEN_HEIGHT - bottomHeight - 150

class FGChooseAddressBgView: UIView {

    var selAddressCallback: ((AMapPOI) -> Void)?
    
    var curPoi: AMapPOI? {
        didSet {
            if pois.count > 0 {
                tableView.reloadSections([0], with: .none)
            } else {
                tableView.reloadData()
            }
            tableViewShowPart()
        }
    }
    var pois: [AMapPOI] = [] {
        didSet {
            tableView.reloadData()
            if pois.count > 0 { tableViewShowAll() }
        }
    }
    
    /// 是否在拖拽
    private var isDragging = false
    /// 滑动方向
    private var isDown = false
    ///
    private var beforeY: CGFloat = 0
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 10
            tableView.estimatedRowHeight = 288.0
            tableView.tableFooterView = UIView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "FGCurAddressCell", bundle: nil), forCellReuseIdentifier: "FGCurAddressCell")
        }
    }
    
    static func loadView() -> FGChooseAddressBgView {
        guard let view = Bundle.main.loadNibNamed("FGChooseAddressBgView", owner: self, options: nil)?.last as? FGChooseAddressBgView else {
            return FGChooseAddressBgView()
        }
        view.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2)
        return view
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FGChooseAddressBgView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? curPoi == nil ? 0 : 1 : pois.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FGCurAddressCell", for: indexPath) as? FGCurAddressCell
            cell?.addressLabel.text = curPoi?.addressDesc
            return cell!
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "cellid")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cellid")
                cell?.backgroundColor = .clear
                cell?.selectionStyle = .none
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.textLabel?.numberOfLines = 2
                cell?.textLabel?.textColor = .darkGray
            }
            cell?.textLabel?.text = pois[indexPath.row].addressDesc
            return cell!
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let curPoi = curPoi { selAddressCallback?(curPoi) }
        case 1:
            selAddressCallback?(pois[indexPath.row])
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != tableView || !isDragging { return }
        isDown = scrollView.contentOffset.y > beforeY
        let y = scrollView.contentOffset.y
        beforeY = y
        if y < 0 {
            if frame.origin.y < tableHide_Y {
                frame.origin.y -= y
                tableView.contentOffset.y = 0
            } else if frame.origin.y > tableHide_Y {
                frame.origin.y = tableHide_Y
            }
        } else if y > 0 {
            if frame.origin.y > tableShow_Y {
                frame.origin.y -= y
                tableView.contentOffset.y = 0
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != tableView { return }
        isDragging = true
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView != tableView { return }
        isDragging = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView != tableView { return }
        if isDown {
            if frame.origin.y > tableShow_Y + 70 { tableViewShowPart()
            } else {
                tableViewShowAll()
            }
        } else {
            if frame.origin.y < tableHide_Y - 70 {
                tableViewShowAll()
            } else {
                tableViewShowPart()
            }
        }
    }
}

extension FGChooseAddressBgView {
    
    func tableViewShowAll() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.frame.origin.y = tableShow_Y
        }
    }
    func tableViewShowPart() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.frame.origin.y = tableHide_Y
        }
    }
}
