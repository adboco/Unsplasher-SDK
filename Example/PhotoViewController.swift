//
//  PhotoViewController.swift
//  Example
//
//  Created by Adrián Bouza Correa on 22/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import UIKit
import Unsplasher
import Hero

class PhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    private let downloadsImageView = UIImageView()
    private let downloadsLabel = UILabel()
    
    private var panGR: UIPanGestureRecognizer!
    
    var photo: Photo?
    var preloadedImage: UIImage?
    var imageHeroID: String?
    
    override func loadView() {
        super.loadView()
        
        imageView.heroID = imageHeroID
        imageView.image = preloadedImage
        
        downloadsImageView.image = UIImage(named: "downloads")
        downloadsImageView.contentMode = .scaleAspectFit
        downloadsLabel.text = "\(photo?.downloads ?? 0)"
        if let color = photo?.color {
            var contrastColor: UIColor
            if color.isDark {
                contrastColor = UIColor(hue: 0, saturation: 0, brightness: 15, alpha: 1.0)
            } else {
                contrastColor = UIColor.darkGray
            }
            downloadsImageView.tintColor = contrastColor
            downloadsLabel.textColor = contrastColor
        }
        
        self.view.addSubview(downloadsImageView)
        self.view.addSubview(downloadsLabel)
        downloadsLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview()
        }
        downloadsImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(downloadsLabel.snp.top).offset(-8)
            make.width.height.equalTo(24)
        }
        
        downloadsLabel.heroModifiers = [.translate(y: 100), .fade, .delay(0.2), .timingFunction(.easeInOut)]
        downloadsImageView.heroModifiers = [.translate(y: 100), .fade, .delay(0.2), .timingFunction(.easeInOut)]
        
        view.bringSubview(toFront: imageView)
        
        // get complete photo info
        guard let photoId = photo?.id else { return }
        Unsplash.shared.photos.photo(id: photoId) { result in
            switch result {
            case .success(let photo):
                self.photo = photo
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.downloadsLabel.text = "\(photo.downloads ?? 0)"
                    })
                }
            case .failure(let error):
                print("Error getting photo: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        // pan gesture to interactive dismiss
        panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        view.addGestureRecognizer(panGR)
        
        // tap to dismiss view controller
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapGR.numberOfTapsRequired = 1
        tapGR.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGR)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // animate view background with photo color
        UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
            self.view.backgroundColor = self.photo?.color
        }, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        // calculate the progress based on how far the user moved
        let translation = panGR.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        
        switch panGR.state {
        case .began:
            // begin the transition as normal
            dismiss(animated: true, completion: nil)
        case .changed:
            Hero.shared.update(progress)
            
            // update views' position based on the translation
            let point = CGPoint(x: translation.x + imageView.center.x, y: translation.y + imageView.center.y)
            Hero.shared.apply(modifiers: [.position(point)], to: imageView)
        default:
            // finish or cancel the transition based on the progress and user's touch velocity
            if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CGPoint {
    
    // Small helper function to add two CGPoints
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
}
