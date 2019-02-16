//
//  Extensions.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 1/31/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit

let imagesCache = NSCache<NSString, AnyObject>()
extension UIImageView {
    
    func loadImagesUsingCacheWithURL( urlString: String ){
        
        self.image = nil
        
        if let cachedImage = imagesCache.object(forKey: urlString as NSString) as? UIImage{
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error ?? " ")
                return
            }
            
            guard let imageData = data else { fatalError() }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: imageData) {
                    imagesCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
            
        }.resume()
    }
    
}
