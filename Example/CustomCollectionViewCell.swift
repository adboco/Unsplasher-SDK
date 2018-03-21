//
//  CustomCollectionViewCell.swift
//  Example
//
//  Created by Adrián Bouza Correa on 22/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import UIKit
import Unsplasher
import Kingfisher
import LGButton

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeButton: LGButton!
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradientLayer.frame = frame
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.35).cgColor, UIColor.clear]
        gradientLayer.locations = [0.0, 0.55]
        imageView.layer.addSublayer(gradientLayer)
        
        imageView.backgroundColor = UIColor.lightGray
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.masksToBounds = true
        
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.masksToBounds = false
        clipsToBounds = true
    }
    
    func configure(with photo: Photo, indexPath: IndexPath) {
        self.imageView.kf.indicatorType = .activity
        self.imageView.kf.setImage(with: photo.urls?.regular, options: [.transition(.fade(0.2))])
        self.userImageView.kf.setImage(with: photo.user?.profileImage?.large)
        self.usernameLabel.text = photo.user?.name
        self.likeButton.leftIconColor = photo.likedByUser == true ? .red : .lightGray
        self.likeButton.tag = indexPath.item
    }
    
}
