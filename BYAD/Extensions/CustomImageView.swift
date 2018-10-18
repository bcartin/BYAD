//
//  CustomImageView.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/27/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    

    
    func loadImage(from urlString: String) {
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        lastURLUsedToLoadImage = urlString
        self.image = nil
        if let cachedImage = imageCache.object(forKey: lastURLUsedToLoadImage! as NSString) {
            self.image = cachedImage
            self.superview?.showSpinner(false)
            return
        }
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            guard let imageData = data else {return}
            if let photoImage = UIImage(data: imageData) {
                imageCache.setObject(photoImage, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    self.image = photoImage
                    self.superview?.showSpinner(false)
                }
            }
            }.resume()
    }
    
    
}
