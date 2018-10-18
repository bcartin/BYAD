//
//  General.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/22/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didCoverDistance = Notification.Name("didCoverDistance")
}

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
    
    static func disabledBlue() -> UIColor {
        return UIColor.rgb(red: 120, green: 176, blue: 228)
    }
    
    
}

extension UIView {
    
    func showSpinner(_ status: Bool) {
        var fadeView: UIView?
        if status == true {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            fadeView?.backgroundColor = UIColor.clear
            fadeView?.tag = 99
            let spinner = UIActivityIndicatorView()
            spinner.style = .whiteLarge
            spinner.color = UIColor.gray
            spinner.center = self.center
            self.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            spinner.startAnimating()
            fadeView?.layer.zPosition = 1
        }
        else {
            for subView in self.subviews {
                if subView.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subView.alpha = 0.0
                    }, completion: { (finished) in
                        subView.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    func findFirstresponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        else {
            for view in self.subviews {
                let firstResponder = view.findFirstresponder()
                if firstResponder != nil {
                    return firstResponder
                }
            }
        }
        return nil
    }
    
    func fadeTo(alphaValue: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat ) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
    }
    
    func setSizeAnchors(height: CGFloat?, width: CGFloat?) {
        translatesAutoresizingMaskIntoConstraints = false
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    func centerHorizontaly(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerVertically(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension UIImage: NSDiscardableContent {
    public func beginContentAccess() -> Bool {
        return true
    }

    public func endContentAccess() {
        //
    }

    public func discardContentIfPossible() {
        //
    }

    public func isContentDiscarded() -> Bool {
        return false
    }


}
