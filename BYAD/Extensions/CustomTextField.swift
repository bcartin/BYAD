//
//  CustomTextField.swift
//  BYAD
//
//  Created by Bernie Cartin on 9/28/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 1, alpha: 1)
        self.font = UIFont(name: "AvenirNext-Regular", size: 18)
        self.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
        self.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
