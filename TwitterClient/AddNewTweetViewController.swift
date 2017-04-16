//
//  AddNewTweetViewController.swift
//  TwitterClient
//
//  Created by Sethi, Pinkesh on 4/16/17.
//  Copyright © 2017 Sethi, Pinkesh. All rights reserved.
//

import UIKit

@objc protocol AddNewTweetViewControllerDelegate {
    @objc optional func addNewTweetViewController(addNewTweetViewController: AddNewTweetViewController, getNewTweet tweet: Tweet )
}
class AddNewTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var tweetCountButton: UIBarButtonItem!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userThumbImageView: UIImageView!
    @IBOutlet weak var tweetTextView: UITextView!
    
    var isReplyToTweet = false
    var replyTweet : Tweet?
    var delegate: AddNewTweetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.delegate = self
        tweetTextView.becomeFirstResponder()
        let user  = User.currentUser
        userScreenNameLabel.text = "@"+(user?.screenName)!
        userNameLabel.text = user?.name
        if user?.profilePhotoUrl != nil{
            userThumbImageView.setImageWith((user?.profilePhotoUrl)!)
        }
        userThumbImageView.layer.cornerRadius = 10.0
        userThumbImageView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
        if isReplyToTweet{
            tweetTextView.text = replyTweet?.senderScreenName
            
            let item = self.navigationItem.rightBarButtonItems?[0]
            item?.title = "Reply"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendTweet(_ sender: Any) {
        if(isReplyToTweet){
            TwitterAPIClient.sharedInstance?.replyTweet(text: tweetTextView.text, id: (replyTweet?.id!)!, success: { (tweet:Tweet) in
                print("Successfully replied to tweet "+tweet.text!)
                self.delegate?.addNewTweetViewController!(addNewTweetViewController: self, getNewTweet: tweet)
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })
        }else{
            TwitterAPIClient.sharedInstance?.sendTweet(text: tweetTextView.text, success: { (tweet:Tweet) in
                print("Sent successfully"+tweet.text!)
                self.delegate?.addNewTweetViewController!(addNewTweetViewController: self, getNewTweet: tweet)
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let remainingCount = 141-(textView.text.characters.count + (text.characters.count - range.length))
        tweetCountButton.title = "\(remainingCount)"
        return textView.text.characters.count + (text.characters.count - range.length) <= 140
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
