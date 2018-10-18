//
//  ConnectionsController.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/5/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class ConnectionsController: UIViewController, Alertable, GADBannerViewDelegate {
    
    
    var connectionsArray: [Connection] = []
    var user: User?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Messages"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    let connectionsTableView: UITableView = {
        let tv = UITableView()
        tv.register(ConnectionCell.self, forCellReuseIdentifier: "matchCell")
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return tv
    }()
    
    var bannerView: GADBannerView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //Ad Banner Config
        bannerView.delegate = self
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Test
//        bannerView.adUnitID = "ca-app-pub-4709796125234322/1018456527"  //Prod
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.shouldPresentLoadingView(true)
        loadData()
        self.user?.observeIfBlocked(handler: { (userID) in
            if let userID = userID {
                if let index = self.connectionsArray.index(where: {$0.personId == userID}) {
                    self.connectionsArray.remove(at: index)
                    self.connectionsTableView.reloadData()
                }
            }
        })
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.titleView = titleLabel
        
        let safeArea = view.safeAreaLayoutGuide
        
        connectionsTableView.delegate = self
        connectionsTableView.dataSource = self
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        view.addSubview(bannerView)
        bannerView.anchor(top: nil, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        bannerView.setSizeAnchors(height: 50, width: nil)
        
        view.addSubview(connectionsTableView)
        connectionsTableView.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: bannerView.topAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    func loadData() {
        connectionsArray.removeAll()
        guard let user = self.user else {return}
        user.loadConnections() { (connection) in
            if let connection = connection {
                        self.connectionsArray.append(connection)
                        connection.observeChanges(handler: { (result) in
                            self.connectionsArray.sort {$0.timeStamp > $1.timeStamp}
                            self.connectionsTableView.reloadData()
                            self.shouldPresentLoadingView(false)
                        })
            }
        }
        self.connectionsTableView.reloadData()
        self.shouldPresentLoadingView(false)
    }
    
    
    
}

extension ConnectionsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = connectionsTableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as! ConnectionCell
        cell.accessoryType = .disclosureIndicator
        if let photoUrl = connectionsArray[indexPath.row].connectionPhotoUrl {
            cell.matchImage.loadImage(from: photoUrl)
        }
        cell.nameLabel.text = connectionsArray[indexPath.row].connectionName
        cell.messageLabel.text = connectionsArray[indexPath.row].lastMessage
        if connectionsArray[indexPath.row].isNew {
            cell.isNewUIView.alpha = 1
            cell.messageLabel.textColor = UIColor.black
        }
        else {
            cell.isNewUIView.alpha = 0
            cell.messageLabel.textColor = UIColor.gray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatController()
        vc.connection = self.connectionsArray[indexPath.row]
        vc.user = self.user
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
}


