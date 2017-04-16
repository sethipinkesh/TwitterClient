//
//  LoginViewController.swift
//  TwitterClient
//
//  Created by Sethi, Pinkesh on 4/14/17.
//  Copyright © 2017 Sethi, Pinkesh. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    @IBAction func onLoginClick(_ sender: Any) {
        TwitterAPIClient.sharedInstance?.login(success: {
            print("Logged in succesfully")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }, failure: { (error:Error?) in
            print(error?.localizedDescription ?? "Some error")
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
