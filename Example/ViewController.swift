//
//  ViewController.swift
//  Example
//
//  Created by Adrian Bouza Correa on 20/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import UIKit
import Unsplasher
import Hero
import Hue
import VegaScrollFlowLayout
import LGButton

// navigation bar related constants
private struct Const {
    
    static let ImageSizeForLargeState: CGFloat = 40
    static let ImageRightMargin: CGFloat = 16
    static let ImageBottomMarginForLargeState: CGFloat = 12
    static let ImageBottomMarginForSmallState: CGFloat = 6
    static let ImageSizeForSmallState: CGFloat = 32
    static let NavBarHeightSmallState: CGFloat = 44
    static let NavBarHeightLargeState: CGFloat = 96.5
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var vegaScrollFlowLayout: VegaScrollFlowLayout!
    let profileImageView = UIImageView()
    
    let reuseIdentifier = "CustomCell"
    
    let itemHeight: CGFloat = 300
    
    internal var currentUser: User?
    
    internal var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        vegaScrollFlowLayout.minimumLineSpacing = 10
        vegaScrollFlowLayout.itemSize = CGSize(width: collectionView.frame.width - 20, height: itemHeight)
        vegaScrollFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.contentInset.bottom = itemHeight
        
        // double tap to like image
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(doubleTap)
        
        // show activity indicator while the app downloads data
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.darkGray
        self.collectionView.backgroundView = activityIndicator
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-activityIndicator.frame.size.height)
        }
        activityIndicator.startAnimating()
        
        // get photos closure
        let getPhotos: () -> Void = {
            Unsplash.shared.photos.photos(orderBy: .latest, curated: false) { result in
                activityIndicator.stopAnimating()
                switch result {
                case .success(let photos):
                    self.photos = photos
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        self.collectionView.endRefreshing()
                    }
                case .failure(let error):
                    print("Error: " + error.localizedDescription)
                }
            }
        }
        
        // get user closure
        let getUser: () -> Void = {
            Unsplash.shared.currentUser.profile { result in
                switch result {
                case .success(let user):
                    self.currentUser = user
                    self.displayProfileButton(for: user)
                case .failure(let error):
                    print("Error: " + error.localizedDescription)
                }
            }
        }
        
        // pull to refresh
        collectionView.addPullToRefresh {
            self.photos = []
            getPhotos()
        }
        
        // authenticate user if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Unsplash.shared.authenticate(self) { result in
                switch result {
                case .success:
                    getUser()
                    getPhotos()
                case .failure(let error):
                    activityIndicator.stopAnimating()
                    print("Error: " + error.localizedDescription)
                }
            }
        }
        
        // animate background with gradient
        setAnimatedGradientBackground(attachTo: self.collectionView, from: [UIColor(hex:"#CCD6E1"), UIColor(hex:"#F7F2EE")], to: [UIColor(hex:"#F7F2EE"), UIColor(hex:"#CCD6E1")])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hideProfileButton(false)
        self.updateAnimatedGradientBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideProfileButton(true)
    }
    
    func displayProfileButton(for user: User) {
        profileImageView.alpha = 0.0
        profileImageView.kf.setImage(with: user.profileImage?.large)
        profileImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        profileImageView.heroID = "profile"
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewProfile(_:)))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // add image view to navigation bar
        self.navigationController?.navigationBar.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.height.equalTo(Const.ImageSizeForLargeState)
            make.width.equalTo(profileImageView.snp.height)
            make.bottom.equalToSuperview().offset(-Const.ImageBottomMarginForLargeState)
            make.right.equalToSuperview().offset(-Const.ImageRightMargin)
        }
        // fade in button
        self.hideProfileButton(false)
    }
    
    func hideProfileButton(_ hide: Bool) {
        self.moveAndResizeImage()
        UIView.animate(withDuration: 0.2) {
            self.profileImageView.alpha = hide ? 0.0 : 1.0
        }
    }
    
    @objc func viewProfile(_ sender: UITapGestureRecognizer) {
        guard let user = self.currentUser else {
            return
        }
        guard let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
            return
        }
        profileViewController.preloadedProfileImage = (sender.view as? UIImageView)?.image
        profileViewController.user = user
        self.navigationController?.heroNavigationAnimationType = .fade
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: point),
            let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else {
            return
        }
        self.likeAction(cell.likeButton)
    }

    @IBAction func likeAction(_ sender: LGButton) {
        guard sender.tag < photos.count else {
            return
        }
        
        // like closure
        let likeClosure: (LikeResult) -> Void = { result in
            switch result {
            case .success(let like):
                self.photos[sender.tag].likedByUser = like.photo.likedByUser
                
                sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 6.0, options: .allowUserInteraction, animations: {
                    sender.leftIconColor = like.photo.likedByUser == true ? .red : .lightGray
                    sender.transform = .identity
                }, completion: nil)
            case .failure(let error):
                print("Error liking photo: \(error.localizedDescription)")
            }
        }
        
        let photo = photos[sender.tag]
        // like or unlike depending of the current state
        if photo.likedByUser == false {
            Unsplash.shared.photos.like(id: photo.id, completion: likeClosure)
        } else {
            Unsplash.shared.photos.unlike(id: photo.id, completion: likeClosure)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    
    private func moveAndResizeImage() {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        profileImageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // resize profile image view
        moveAndResizeImage()
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomCollectionViewCell
        
        let photo = photos[indexPath.item]
        cell.configure(with: photo, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = .init(scaleX: 0.7, y: 0.7)
        cell.alpha = 0.5
        UIView.animate(withDuration: 0.5) {
            cell.transform = .identity
            cell.alpha = 1.0
        }
        
        guard indexPath.item == self.photos.count - 1 else {
            return
        }
        
        // getting next page of photos when the las cell will be displayed
        Unsplash.shared.photos.next { result in
            switch result {
            case .success(let photos):
                self.photos = self.photos + photos
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
            case .failure(let error):
                print("Error: " + error.localizedDescription)
            }
        }
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else {
            return
        }
        cell.imageView.heroID = "photo\(photo.id)"
        
        guard let photoViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController else {
            return
        }
        photoViewController.heroModalAnimationType = .fade
        photoViewController.imageHeroID = cell.imageView.heroID
        photoViewController.preloadedImage = cell.imageView.image
        photoViewController.photo = photo
        present(photoViewController, animated: true, completion: nil)
    }
    
}
