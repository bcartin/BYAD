//
//  MessageTextView.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/6/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class MessageTextView: UITextView {
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidEndEditingNotification, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0)
        placeholderLabel.centerVertically(in: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    func showPlaceholder() {
        placeholderLabel.isHidden = false
    }
    
    
    fileprivate let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Message"
        label.textColor = UIColor.lightGray
        return label
    }()
    
    
}


