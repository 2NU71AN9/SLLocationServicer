//
//  FGMapChooseAddressViewController.swift
//  FBMerchant
//
//  Created by Kevin on 2019/7/1.
//  Copyright © 2019 cn. All rights reserved.
//

import UIKit
import RxSwift
import SLSupportLibrary

class FGMapChooseAddressViewController: UIViewController {
    
    @objc var selAddressCallback: ((AMapPOI) -> Void)?
    
    private lazy var bottomView: FGChooseAddressBgView = {
        let view = FGChooseAddressBgView.loadView()
        view.selAddressCallback = { [weak self] (poi) in
            self?.selAddressCallback?(poi)
            self?.dissmiss()
        }
        return view
    }()
    
    private lazy var mapView: MAMapView = {
        let mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        return mapView
    }()
    
    private lazy var headView: FGChoosCitySearchView = {
        let view = FGChoosCitySearchView.loadView()
        view.frame = CGRect(x: 0, y: naviCtrHeight, width: SCREEN_WIDTH, height: 50)
        view.chooseCityCallback = { [weak self] in
            self?.chooseCityAction()
        }
        view.chooseAddressCallback = { [weak self] in
            self?.chooseAddressCallback()
        }
        return view
    }()
    
    /// 打点
    private let pointAnnotation = MAPointAnnotation()
    /// 地址选择的
    private var selPoi: AMapPOI? {
        didSet {
            bottomView.curPoi = selPoi
            if let latitude = selPoi?.location.latitude,
                let longitude = selPoi?.location.longitude {
                location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            }
        }
    }
    /// 定位获取的
    private var ltModel: LocationModel? {
        didSet {
            city = ltModel?.placemark?.locality
            location = ltModel?.location
        }
    }
    private var location: CLLocation? {
        didSet {
            moveMap()
            makePoint()
            poiAroundSearch()
        }
    }
    private var city: String? {
        didSet {
            headView.city = city ?? "选择城市"
            
            mapView.removeAnnotation(pointAnnotation)
            selPoi = nil
            location = nil
            pois = []
        }
    }
    
    /// POI搜索
    private lazy var search: AMapSearchAPI? = {
        let search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    ///
    private lazy var aroundRequest: AMapPOIAroundSearchRequest = {
        let request = AMapPOIAroundSearchRequest()
        request.requireExtension = true
        request.city = city
        request.sortrule = 0
        request.requireExtension = true
        return request
    }()
    private lazy var keywordsRequest: AMapPOIKeywordsSearchRequest = {
        let request = AMapPOIKeywordsSearchRequest()
        request.requireExtension = true
        request.city = city
        //        request.keywords = "北京"
        request.cityLimit = true
        request.requireSubPOIs = true
        return request
    }()
    
    private var pois: [AMapPOI] = [] {
        didSet {
            bottomView.pois = pois
        }
    }
    
    private let bag = DisposeBag()
    
    init(complete: @escaping (AMapPOI) -> Void) {
        super.init(nibName: nil, bundle: nil)
        selAddressCallback = complete
        modalPresentationStyle = .fullScreen
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .fullScreen
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    @objc static func makeVC(_ complete: @escaping (AMapPOI) -> Void) -> UIViewController {
        let vc = FGMapChooseAddressViewController(complete: complete)
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        return navi
    }
}

// MARK: - life circle
extension FGMapChooseAddressViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setRx()
        LocationService.turnOn()
    }
}

// MARK: - MAMapViewDelegate
extension FGMapChooseAddressViewController: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            annotationView!.image = UIImage(named: "locationPoint")
            annotationView!.centerOffset = CGPoint(x: 0, y: -18);
            return annotationView!
        }
        return nil
    }
    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
        if wasUserAction { bottomView.tableViewShowPart() }
    }
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
    }
}
// MARK: - AMapSearchDelegate
extension FGMapChooseAddressViewController: AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        pois = response.pois
    }
}

extension FGMapChooseAddressViewController {
    @objc private func dissmiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setUI() {
        title = "选择地址"
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navi_back_black22"), style: .plain, target: self, action: #selector(dissmiss))
        
        view.addSubview(mapView)
        view.addSubview(headView)
        view.addSubview(bottomView)
    }
    
    private func setRx() {
        LocationService.shared.locationSubject.subscribe(onNext: { [weak self] (error, lms) in
            if let lms = lms {
                self?.ltModel = lms
            }
        }).disposed(by: bag)
    }
    
    private func chooseCityAction() {
        let vc = SLCitySelectorViewController()
        vc.selectCitySubject.subscribe(onNext: { [weak self] (city) in
            self?.city = city
            self?.poiKeywordsSearch()
        }).disposed(by: bag)
        let navi = UINavigationController(rootViewController: vc)
        present(navi, animated: true, completion: nil)
    }
    private func chooseAddressCallback() {
        let vc = FGSearchAddressViewController(city ?? "")
        vc.selectPoiCallback = { [weak self] (poi) in
            self?.selPoi = poi
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func makePoint() {
        if let latitude = location?.coordinate.latitude,
            let longitude = location?.coordinate.longitude {
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.addAnnotation(pointAnnotation)
        }
    }
    
    private func poiAroundSearch() {
        if let latitude = location?.coordinate.latitude,
            let longitude = location?.coordinate.longitude {
            aroundRequest.location = AMapGeoPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
            search?.aMapPOIAroundSearch(aroundRequest)
        }
    }
    private func poiKeywordsSearch() {
        keywordsRequest.keywords = city
        search?.aMapPOIKeywordsSearch(keywordsRequest)
    }
    
    private func moveMap() {
        if let coordinate = location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude-0.01, longitude: coordinate.longitude)
            mapView.centerCoordinate = center
            mapView.setZoomLevel(13, animated: true)
            let region = MACoordinateRegion(center: center, span: MACoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
            mapView.setRegion(region, animated: true)
        }
    }
}
