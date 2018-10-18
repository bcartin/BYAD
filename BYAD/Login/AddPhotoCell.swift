//
//  AddPhotoCell.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/23/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

protocol AddPhotoCellDelegate {
    func didTapAddPhoto(for cell: AddPhotoCell)
    func didTapDelete(for cell: AddPhotoCell)
}

class AddPhotoCell: UICollectionViewCell {
    
    var delegate: AddPhotoCellDelegate?
    var cellIndex: Int?
    
    lazy var addPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "AddPhoto"), for: .normal)
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleAddPhoto), for: .touchUpInside)
        return button
    }()
    
    let photoView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.backgroundColor = UIColor(white: 0, alpha: 0.1)
        button.layer.cornerRadius = 20
        return button
    }()
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        addSubview(addPhotoButton)
        addPhotoButton.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        photoView.addSubview(photoImageView)
        photoImageView.anchor(top: photoView.topAnchor, left: photoView.leftAnchor, bottom: photoView.bottomAnchor, right: photoView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        addSubview(photoView)
        photoView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        photoView.addSubview(deleteButton)
        deleteButton.anchor(top: photoView.topAnchor, left: photoView.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 2, paddingBottom: 0, paddingRight: 0)
        deleteButton.setSizeAnchors(height: 40, width: 40)
    }
    
    @objc func handleAddPhoto() {
        delegate?.didTapAddPhoto(for: self)
    }
    
    @objc func handleDelete() {
        delegate?.didTapDelete(for: self)
    }
}
