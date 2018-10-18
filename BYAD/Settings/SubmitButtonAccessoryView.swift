//
//  SubmitButtonAccessoryView.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/1/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

protocol SubmitButtonAccessoryViewDelegate {
    func didSubmit()
}

class SubmitButtonAccessoryView: UIView {
    
    var delegate: SubmitButtonAccessoryViewDelegate?
    
    let mainView: UIView = {
        let view = UIView()
        return view
    }()

    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        mainView.addSubview(submitButton)
        submitButton.anchor(top: mainView.topAnchor, left: mainView.leftAnchor, bottom: mainView.bottomAnchor, right: mainView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        submitButton.setSizeAnchors(height: 60, width: nil)
        
        addSubview(mainView)
        mainView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSubmit() {
        delegate?.didSubmit()
    }
}

