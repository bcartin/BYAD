//
//  ReceivedMessageCell.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/5/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class ReceivedMessageCell: UITableViewCell {
    
    var message: String = ""
    var timeStam = Date()
    var userImage = UIImage(named: "flame.png")
    var messageLabelWidthConstraint: NSLayoutConstraint?
    
    
    let messageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let cornerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 50
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        return label
    }()
    
    let senderImage: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
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
        contentView.addSubview(senderImage)
        contentView.addSubview(cornerView)
        contentView.addSubview(messageView)
        
        messageLabelWidthConstraint = NSLayoutConstraint(item: messageLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0)
        messageLabelWidthConstraint?.isActive = true
        
        cornerView.setSizeAnchors(height: 15, width: 15)
        senderImage.setSizeAnchors(height: 20, width: 20)
        
        senderImage.anchor(top: nil, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: contentView.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 5, paddingRight: 0)
        messageView.anchor(top: contentView.safeAreaLayoutGuide.topAnchor, left: senderImage.rightAnchor, bottom: contentView.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0)
        cornerView.anchor(top: nil, left: senderImage.rightAnchor, bottom: contentView.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 5, paddingRight: 0)
        
        messageView.addSubview(messageLabel)
        messageLabel.anchor(top: messageView.topAnchor, left: messageView.leftAnchor, bottom: messageView.bottomAnchor, right: messageView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

