//
//  AboutController.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/17/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class AboutController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    let titleImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "HeaderText.png"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let versionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.text = "Version 2.0.0"
        return label
    }()
    
    let byadLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.text = "BYAD developed by GarsonTech 2018"
        return label
    }()
    
    let termsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms & Conditions", for: .normal)
        button.addTarget(self, action: #selector(handleTermsTapped), for: .touchUpInside)
        return button
    }()
    
    let creditsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.text = "Icons & Graphics Credits"
        return label
    }()
    
    let creditsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.text = "Authors from flatIcon.com: Smashicons, Freepik, Google, Banking Icons, Maxim Basinski, Bodgan Rosu, Cole Bemis, Iconnice, Yannick, Dave Gandy. "
        return label
    }()
    
    let contactUsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.text = "Contact Us: garsontech@gmail.com"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.titleView = titleLabel
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(titleImage)
        titleImage.setSizeAnchors(height: 70, width: 200)
        titleImage.anchor(top: safeArea.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        titleImage.centerHorizontaly(in: view)
        
        view.addSubview(versionLabel)
        versionLabel.anchor(top: titleImage.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(byadLabel)
        byadLabel.anchor(top: versionLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(termsButton)
        termsButton.anchor(top: byadLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        termsButton.centerHorizontaly(in: view)
        
        view.addSubview(creditsTitleLabel)
        creditsTitleLabel.anchor(top: termsButton.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(creditsLabel)
        creditsLabel.anchor(top: creditsTitleLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 15, paddingLeft: 60, paddingBottom: 0, paddingRight: 60)
        
        view.addSubview(contactUsLabel)
        contactUsLabel.anchor(top: creditsLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
    }
    
    @objc fileprivate func handleTermsTapped() {
        let vc = TermsController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
