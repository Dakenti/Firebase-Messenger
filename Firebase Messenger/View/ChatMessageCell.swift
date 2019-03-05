//
//  ChatMessageCell.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 2/24/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)

    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.textColor = .white
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let bubleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "nedstark")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var bubleViewWidthAnchor: NSLayoutConstraint?
    var bubleViewRightAnchor: NSLayoutConstraint?
    var bubleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //ios 9 constraints
        bubleViewRightAnchor = bubleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubleViewRightAnchor?.isActive = true
        
        bubleViewLeftAnchor = bubleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubleViewWidthAnchor = bubleView.widthAnchor.constraint(equalToConstant: 200)
        bubleViewWidthAnchor?.isActive = true
        
        bubleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //x,y,w,h
        textView.leftAnchor.constraint(equalTo: bubleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
