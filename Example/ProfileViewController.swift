//
//  ProfileViewController.swift
//  Example
//
//  Created by Adrián Bouza Correa on 28/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import UIKit
import Unsplasher
import SnapKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var profileImageView: UIImageView = UIImageView()
    
    var user: User?
    var preloadedProfileImage: UIImage?
    
    override func loadView() {
        super.loadView()
        
        profileImageView.heroID = "profile"
        profileImageView.image = preloadedProfileImage
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 50
        
        profileImageView.kf.setImage(with: user?.profileImage?.large)
        
        let headerView = UIView()
        headerView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(100)
        }
        
        self.tableView.tableHeaderView = headerView
        
        headerView.snp.makeConstraints { (make) in
            make.width.equalTo(self.tableView)
            make.centerX.equalTo(self.tableView)
            make.height.equalTo(120)
        }
        
        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = user?.username
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        let getProfile: () -> Void = {
            Unsplash.shared.currentUser.profile { result in
                DispatchQueue.main.async {
                    self.tableView.endRefreshing()
                }
                switch result {
                case .success(let user):
                    self.user = user
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Error updating profile info: \(error.localizedDescription)")
                }
            }
        }
        
        self.tableView.addPullToRefresh {
            getProfile()
        }
        
        setAnimatedGradientBackground(attachTo: self.tableView, from: [UIColor(hex:"#CCD6E1"), UIColor(hex:"#F7F2EE")], to: [UIColor(hex:"#F7F2EE"), UIColor(hex:"#CCD6E1")])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateAnimatedGradientBackground()
    }

}

// MARK: - Table view data source

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "First Name"
            cell.detailTextLabel?.text = self.user?.firstName
        case 1:
            cell.textLabel?.text = "Last Name"
            cell.detailTextLabel?.text = self.user?.lastName
        case 2:
            cell.textLabel?.text = "Followers"
            cell.detailTextLabel?.text = "\(self.user?.followersCount ?? 0)"
        case 3:
            cell.textLabel?.text = "Following"
            cell.detailTextLabel?.text = "\(self.user?.followingCount ?? 0)"
        case 4:
            cell.textLabel?.text = "Downloads"
            cell.detailTextLabel?.text = "\(self.user?.downloads ?? 0)"
        case 5:
            cell.textLabel?.text = "Bio"
            cell.detailTextLabel?.text = self.user?.bio
        default:
            break
        }
        
        return cell
    }
    
}

// MARK: - Table view delegate

extension ProfileViewController: UITableViewDelegate {
    
    
    
}
