//
//  ConnectionCell.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/5/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class ConnectionCell: UITableViewCell {
    

    let matchImage: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 35
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        return label
    }()
    
    let isNewUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        view.layer.cornerRadius = 7.5
        view.alpha = 0
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func initUI() {
        
        self.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        contentView.addSubview(matchImage)
        matchImage.setSizeAnchors(height: 70, width: 70)
        matchImage.anchor(top: contentView.safeAreaLayoutGuide.topAnchor, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: contentView.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0)
        
        contentView.addSubview(nameLabel)
        nameLabel.anchor(top: contentView.safeAreaLayoutGuide.topAnchor, left: matchImage.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0)
        
        contentView.addSubview(messageLabel)
        messageLabel.anchor(top: nameLabel.bottomAnchor, left: matchImage.rightAnchor, bottom: nil, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 5)
        
        contentView.addSubview(isNewUIView)
        isNewUIView.setSizeAnchors(height: 15, width: 15)
        isNewUIView.anchor(top: matchImage.topAnchor, left: nil, bottom: nil, right: matchImage.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
    }

    
}
