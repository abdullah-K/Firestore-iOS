//
//  HomeViewController.swift
//  Firestore-iOS
//
//  Created by Abdullah Khan on 2019-09-14.
//  Copyright © 2019 Abdullah Khan. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
//            let uid = user.firstName
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    

}
