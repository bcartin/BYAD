//
//  MainController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/21/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase


var imageCache = NSCache<NSString, UIImage>()
var userCache = NSCache<NSString, User>()
var screenOrigin: CGFloat = 0

class MainController: UIViewController, Alertable, GADBannerViewDelegate {
    
    var user: User?
    var people = People()
    var isOnline: Bool? {
        didSet {
            switchStatus()
        }
    }
    var isExpanded = false
    
    var statusHeightConstraint: NSLayoutConstraint?
    
    lazy var peopleCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 10), collectionViewLayout: CustomLayout())
        cv.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        cv.register(PeopleCell.self, forCellWithReuseIdentifier: C_CELLID)
        return cv
    }()
    
    let statusBackgroundImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "texture.jpg"))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 203, green: 203, blue: 203)
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    let sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        view.layer.cornerRadius = 15
        return view
    }()
    
    lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "offline.png")
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let statusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OFFLINE", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        button.addTarget(self, action: #selector(handleStatusExpand), for: .touchUpInside)
        return button
    }()
    
    let offlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return view
    }()
    
    let offlineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cloud.png")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let offlineLabel: UILabel = {
        let label = UILabel()
        label.text = "You're Offline. \n Go online to see people around you."
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Bold", size: 18)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    var bannerView: GADBannerView!
    
    let noResultsView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return view
    }()
    
    let noResultsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noResults.png")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "OH NO! \n Nobody is looking for a drink right now."
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Bold", size: 18)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        setupDelegates()
        setupUI()
        setUpNavBar()
        
        
        //Ad Banner Config
        bannerView.delegate = self
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Test
        //        bannerView.adUnitID = "ca-app-pub-4709796125234322/1018456527"  //Prod
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
        if let uid = Auth.auth().currentUser?.uid {
            LocationServices.shared.checkLocationAuthStatus()
            NotificationService.shared.configure()
            user = User(uid: uid)
            user?.loadUserDetails(completion: { (error) in
                if let err = error {
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    return
                }
                RequestServices.shared.observeRequests()
                RequestServices.shared.observeSentRequest()
                self.isOnline = self.user?.isOnline
                //---
                self.loadUsers()
                //---
                self.checkIfBlocked()
                self.checkIfUnblocked()
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.handleDidCoverDistance(_:)), name: .didCoverDistance, object: nil)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        imageCache.removeAllObjects()
        userCache.removeAllObjects()
    }
    
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        if let uid = Auth.auth().currentUser?.uid {
//            let user = User(uid: uid)
//            user.updateUserDetails(with: [C_NOTIFICATIONSTOKEN: fcmToken])
//        }
//    }
    
    func setupUI() {
//        setNeedsStatusBarAppearanceUpdate()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        let safeArea = view.safeAreaLayoutGuide
        
        statusView.addSubview(statusBackgroundImage)
        statusBackgroundImage.anchor(top: statusView.topAnchor, left: statusView.leftAnchor, bottom: statusView.bottomAnchor, right: statusView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        statusView.addSubview(sliderView)
        sliderView.anchor(top: statusView.topAnchor, left: statusView.leftAnchor, bottom: nil, right: statusView.rightAnchor, paddingTop: 10, paddingLeft: 100, paddingBottom: 0, paddingRight: 100)
        sliderView.setSizeAnchors(height: 30, width: nil)
        sliderView.alpha = 0
        
        sliderView.addSubview(statusImageView)
        statusImageView.anchor(top: sliderView.topAnchor, left: sliderView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        statusImageView.setSizeAnchors(height: 30, width: 30)
        
        statusView.addSubview(statusButton)
        statusButton.anchor(top: nil, left: nil, bottom: statusView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -5, paddingRight: 0)
        statusButton.centerHorizontaly(in: statusView)
        
        view.addSubview(statusView)
        statusView.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 1, paddingBottom: 0, paddingRight: 1)
        statusHeightConstraint = NSLayoutConstraint(item: self.statusView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 20)
        statusHeightConstraint?.isActive = true
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        view.addSubview(bannerView)
        bannerView.anchor(top: nil, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        bannerView.setSizeAnchors(height: 50, width: nil)
        
        
        offlineView.addSubview(offlineImageView)
        offlineImageView.setSizeAnchors(height: 256, width: 256)
        offlineImageView.anchor(top: offlineView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        offlineImageView.centerHorizontaly(in: offlineView)
        
        offlineView.addSubview(offlineLabel)
        offlineLabel.anchor(top: offlineImageView.bottomAnchor, left: offlineView.leftAnchor, bottom: nil, right: offlineView.rightAnchor, paddingTop: 15, paddingLeft: 5, paddingBottom: 0, paddingRight: 5)
        
        view.addSubview(offlineView)
        offlineView.anchor(top: statusView.bottomAnchor, left: safeArea.leftAnchor, bottom: bannerView.topAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(peopleCollectionView)
        peopleCollectionView.anchor(top: statusView.bottomAnchor, left: safeArea.leftAnchor, bottom: bannerView.topAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5)
        
        noResultsView.addSubview(noResultsImage)
        noResultsImage.setSizeAnchors(height: 256, width: 256)
        noResultsImage.anchor(top: noResultsView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        noResultsImage.centerHorizontaly(in: noResultsView)
        
        noResultsView.addSubview(noResultsLabel)
        noResultsLabel.anchor(top: noResultsImage.bottomAnchor, left: noResultsView.leftAnchor, bottom: nil, right: noResultsView.rightAnchor, paddingTop: 15, paddingLeft: 50, paddingBottom: 0, paddingRight: 50)
        
        view.addSubview(noResultsView)
        noResultsView.anchor(top: statusView.bottomAnchor, left: safeArea.leftAnchor, bottom: bannerView.topAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
//        noResultsView.alpha = 0
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(statusImageSwiped(gestureRecognizer:)))
        statusImageView.addGestureRecognizer(gesture)
        
        
    }
    
    
    fileprivate func setUpNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.mainBlue()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let titleImage = UIImageView(image: #imageLiteral(resourceName: "HeaderTextWhite"))
        titleImage.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImage
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "chat").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleChatTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "user").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleUserTapped))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupDelegates() {
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        if let layout = peopleCollectionView.collectionViewLayout as? CustomLayout {
            layout.delegate = self
        }
    }
    
    fileprivate func loadUsers() {
        self.people.peopleArray.removeAll()
        self.peopleCollectionView.reloadData()
        self.people.user = self.user
        self.people.loadPeopleGeo(handler: { (error) in
            if let err = error {
                self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                return
            }
            self.peopleCollectionView.reloadData()
        })
        self.people.observePeopleExit(handler: { (userID) in
            if let userID = userID {
                if let index = self.people.peopleArray.index(where: {$0.uid == userID}) {
                    self.people.peopleArray.remove(at: index)
                    self.peopleCollectionView.reloadData()                    
                }
            }
        })
    }
    
    @objc fileprivate func handleUserTapped() {
        let profileController = ProfileController()
        profileController.user = self.user
        profileController.displaySettingsButton = true
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    

    @objc fileprivate func handleChatTapped() {

//        var userDictionary: [String:Any] = [:]
//        let uid = NSUUID().uuidString
//        userDictionary[C_UID] = uid
//        userDictionary[C_NAME] = "Nicole"
//        userDictionary[C_GENDER] = 1
//        userDictionary[C_PREFEREDGENDER] = 0
//        userDictionary[C_MINAGE] = 18
//        userDictionary[C_MAXAGE] = 50
//        userDictionary[C_DOB] = "03-15-1995"
//        userDictionary[C_AGE] = 24
//        userDictionary[C_FAVORITEDRINK] = "Wine"
//        userDictionary[C_ISONLINE] = false
//        userDictionary[C_PHOTOURL] = ["w18":"https://firebasestorage.googleapis.com/v0/b/byad-e937e.appspot.com/o/userImages%2Fw18.jpg?alt=media&token=83dbc937-0e2d-4af7-8f15-99c2a2358e9f"]
//        let user = User(uid: uid)
//        user.updateUserDetails(with: userDictionary)
        
        
        let vc = ConnectionsController()
        vc.user = self.user
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    
    
    
    fileprivate func checkIfBlocked() {
        user?.observeIfBlocked(handler: { (userID) in
            if let userID = userID {
                if let index = self.people.peopleArray.index(where: {$0.uid == userID}) {
                    self.people.peopleArray.remove(at: index)
                    self.peopleCollectionView.reloadData()
                    
                }
            }
        })
    }
    
    fileprivate func checkIfUnblocked() {
        user?.observeIfUnblocked(handler: { (userID) in
            let user = User(uid: userID!)
            user.resetUserLocation()
        })
    }
    
    @objc fileprivate func handleStatusExpand() {
        if !isExpanded {
            view.layoutIfNeeded()
            self.statusHeightConstraint?.constant = 60
            UIView.animate(withDuration: 0.5) {
                self.sliderView.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
        else {
            view.layoutIfNeeded()
            self.statusHeightConstraint?.constant = 20
            UIView.animate(withDuration: 0.5) {
                self.sliderView.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
        isExpanded = !isExpanded
    }
    
    @objc fileprivate func statusImageSwiped(gestureRecognizer : UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: sliderView)
        guard let isOnline = self.isOnline else {return}
        if !isOnline {
            statusImageView.center = CGPoint(x: 15 + labelPoint.x, y: statusImageView.center.y)
        }
        else {
            statusImageView.center = CGPoint(x: (sliderView.bounds.width - 15) + labelPoint.x, y: statusImageView.center.y)
        }
        
        if gestureRecognizer.state == .ended {
            
            var goOnline = false
            var changeStatus = false
            
            if statusImageView.center.x > (sliderView.bounds.width / 2) {
                statusImageView.center = CGPoint(x: sliderView.bounds.width - 15, y: 15.0)
                if !isOnline {
                    goOnline = true
                    changeStatus = true
                }
            }
            else {
                statusImageView.center = CGPoint(x: 15.0, y: 15.0)
                if isOnline {
                    goOnline = false
                    changeStatus = true
                }
            }
            
            if changeStatus {
                self.isOnline = goOnline
                self.user?.resetUserLocation()
                handleStatusExpand()
                if goOnline {
                    loadUsers()
                }
            }
            
            
        }
    }
    
    fileprivate func switchStatus() {
        guard let isOnline = self.isOnline else {return}
        if !isOnline {
            statusImageView.image = UIImage.init(named: "offline.png")
            statusImageView.center = CGPoint(x: 15.0, y: 15.0)
            statusButton.setTitleColor(.red, for: .normal)
            statusButton.setTitle("OFFLINE", for: .normal)
            self.offlineView.alpha = 1
            self.peopleCollectionView.alpha = 0
            self.noResultsView.alpha = 0
        }
        else {
            statusImageView.image = UIImage.init(named: "online.png")
            statusImageView.center = CGPoint(x: sliderView.bounds.width - 15, y: 15)
            statusButton.setTitleColor(UIColor.rgb(red: 92, green: 197, blue: 59), for: .normal)
            statusButton.setTitle("ONLINE", for: .normal)
            self.offlineView.alpha = 0
            self.peopleCollectionView.alpha = 1
            peopleCollectionView.reloadData()
        }
        self.user?.isOnline = self.isOnline
        
    }
    
    @objc fileprivate func handleDidCoverDistance(_ notification: Notification) {
        loadUsers()
    }
}


extension MainController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = people.peopleArray.count
        if isOnline ?? false {
            if count == 0 {
                noResultsView.alpha = 1
            }
            else {
                noResultsView.alpha = 0
            }
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = peopleCollectionView.dequeueReusableCell(withReuseIdentifier: C_CELLID, for: indexPath) as! PeopleCell
        cell.personPhoto.loadImage(from: people.peopleArray[indexPath.item].photosUrls[0])
        let name = people.peopleArray[indexPath.item].name ?? ""
        let age = String(people.peopleArray[indexPath.item].age ?? 0)
        let drink = people.peopleArray[indexPath.item].favoriteDrink ?? ""
        cell.nameLabel.text = name + ", " + age
        cell.drinkLabel.text = drink
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProfileController()
        vc.user = people.peopleArray[indexPath.item]
        vc.displayByadButton = true
        vc.displayActionsButton = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MainController: CustomLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        if indexPath.item < people.peopleArray.count {
            
            if indexPath.row == 1 || indexPath.row == 3 {
                height = ((collectionView.frame.height / 2) - 2) * 1.25
            }
            else {
                height = ((collectionView.frame.height / 2) - 2) //* 1.1
            }
        
        }
        return height
    }
    
    
}

