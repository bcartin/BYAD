//
//  CacheController.swift
//  BYAD
//
//  Created by Bernie Cartin on 9/28/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import CoreData

class CacheController: UIViewController, Alertable {
    
    var user: User?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Clear Cache"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Cache helps the app run faster and use less data. \n Clearing cache may free up space on your device."
        label.numberOfLines = 0
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.textColor = UIColor(white: 0, alpha: 0.5)
        label.textAlignment = .center
        return label
    }()
    
    let imageCacheView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let userCacheView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let allCacheView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let imagesCacheChevron: UIImageView =   {
        let image = UIImageView(image: UIImage(named: "right-chevron.png"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    let userCacheChevron: UIImageView =   {
        let image = UIImageView(image: UIImage(named: "right-chevron.png"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    let allCacheChevron: UIImageView =   {
        let image = UIImageView(image: UIImage(named: "right-chevron.png"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    
    let imagesCacheButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Images Cache", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        button.addTarget(self, action: #selector(handleClearImageCache), for: .touchUpInside)
        return button
    }()
    
    let usersCacheButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Users Cache", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        button.addTarget(self, action: #selector(handleClearUserCache), for: .touchUpInside)
        return button
    }()
    
    let allCacheButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear All Cache", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        button.addTarget(self, action: #selector(handleClearAllCache), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.titleView = titleLabel
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(imageCacheView)
        imageCacheView.anchor(top: descriptionLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 50, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        imageCacheView.setSizeAnchors(height: 50, width: nil)

        imageCacheView.addSubview(imagesCacheChevron)
        imagesCacheChevron.anchor(top: imageCacheView.topAnchor, left: nil, bottom: imageCacheView.bottomAnchor, right: imageCacheView.rightAnchor, paddingTop: 17, paddingLeft: 0, paddingBottom: 17, paddingRight: 11)
        imagesCacheChevron.setSizeAnchors(height: 16, width: 16)
        imageCacheView.addSubview(imagesCacheButton)
        imagesCacheButton.anchor(top: imageCacheView.topAnchor, left: imageCacheView.leftAnchor, bottom: imageCacheView.bottomAnchor, right: imageCacheView.rightAnchor, paddingTop: 0, paddingLeft: 21, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(userCacheView)
        userCacheView.anchor(top: imageCacheView.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 10, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        userCacheView.setSizeAnchors(height: 50, width: nil)

        userCacheView.addSubview(userCacheChevron)
        userCacheChevron.anchor(top: userCacheView.topAnchor, left: nil, bottom: userCacheView.bottomAnchor, right: userCacheView.rightAnchor, paddingTop: 17, paddingLeft: 0, paddingBottom: 17, paddingRight: 11)
        userCacheChevron.setSizeAnchors(height: 16, width: 16)
        userCacheView.addSubview(usersCacheButton)
        usersCacheButton.anchor(top: userCacheView.topAnchor, left: userCacheView.leftAnchor, bottom: userCacheView.bottomAnchor, right: userCacheView.rightAnchor, paddingTop: 0, paddingLeft: 21, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(allCacheView)
        allCacheView.anchor(top: userCacheView.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 10, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        allCacheView.setSizeAnchors(height: 50, width: nil)
        
        allCacheView.addSubview(allCacheChevron)
        allCacheChevron.anchor(top: allCacheView.topAnchor, left: nil, bottom: allCacheView.bottomAnchor, right: allCacheView.rightAnchor, paddingTop: 17, paddingLeft: 0, paddingBottom: 17, paddingRight: 11)
        allCacheChevron.setSizeAnchors(height: 16, width: 16)
        allCacheView.addSubview(allCacheButton)
        allCacheButton.anchor(top: allCacheView.topAnchor, left: allCacheView.leftAnchor, bottom: allCacheView.bottomAnchor, right: allCacheView.rightAnchor, paddingTop: 0, paddingLeft: 21, paddingBottom: 0, paddingRight: 0)
    }
    
    fileprivate func clearImageCache() {
        imageCache.removeAllObjects()
    }
    
    fileprivate func clearUsersCache() {
        userCache.removeAllObjects()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: C_REQUESTS)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            self.showAlert(title: C_ERROR, msg: "There was an error clearing the users cache.")
        }
        self.showMessage(message: "Cache Cleared", center: nil)
    }
    
    @objc fileprivate func handleClearImageCache() {
        clearImageCache()
        self.showMessage(message: "Cache Cleared", center: nil)
    }

    
    @objc fileprivate func handleClearUserCache() {
        clearUsersCache()
    }
    
    @objc fileprivate func handleClearAllCache() {
        clearImageCache()
        clearUsersCache()
    }
    

}
