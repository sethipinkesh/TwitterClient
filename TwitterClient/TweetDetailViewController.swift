//
//  TweetDetailViewController.swift
//  TwitterClient
//
//  Created by Sethi, Pinkesh on 4/15/17.
//  Copyright © 2017 Sethi, Pinkesh. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController, AddNewTweetViewControllerDelegate {
    var tweet: Tweet!
    
    @IBOutlet weak var favoritesImageView: UIButton!
    @IBOutlet weak var retweetImageView: UIButton!
    @IBOutlet weak var replyImageView: UIButton!
    @IBOutlet weak var retweetedNotifyImageView: UIImageView!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var retweetCountsLabel: UILabel!
    @IBOutlet weak var tweetTimeLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var senderScreenNameLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var retweetedSenderNameLabel: UILabel!
    @IBOutlet weak var senderThumbImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillViewData()
        // Do any additional setup after loading the view.
    }

    func fillViewData(){
        if tweet != nil{
            favoritesCountLabel.text = "\(tweet.favouritesCount)"
            retweetCountsLabel.text = "\(tweet.retweetCount)"
            
            tweetTextLabel.text = tweet.text
            senderNameLabel.text = tweet.senderName
            senderScreenNameLabel.text = tweet.senderScreenName
            if tweet.senderProfileImageUrl != nil{
                senderThumbImageView.setImageWith(tweet.senderProfileImageUrl!)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            let timeStampStr = dateFormatter.string(from: tweet.timeStamp!)
            
            tweetTimeLabel.text = timeStampStr
            
            senderThumbImageView.layer.cornerRadius = 10.0
            senderThumbImageView.layer.masksToBounds = true
            
            if tweet.didUserRetweet {
                retweetImageView.setBackgroundImage(UIImage(named: "retweet_sel_ic.png"), for: UIControlState.normal)
            }
            
            if tweet.didUserFavorites {
                favoritesImageView.setBackgroundImage(UIImage(named: "favorite_sel_ic.png"), for: UIControlState.normal)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTweetReplyClick(_ sender: Any) {
        print("Click on reply button")
        
//        TwitterAPIClient.sharedInstance?.replyTweet(text: ("@"+tweet.senderScreenName!), id: tweet.id!, success: { (tweet:Tweet) in
//            print("Successfully replied to tweet "+tweet.text!)
//        }, failure: { (error:Error) in
//            print(error.localizedDescription)
//        })
    }

    @IBAction func onRetweetClick(_ sender: Any) {
        if !tweet.didUserRetweet{
            TwitterAPIClient.sharedInstance?.retweetTweet(id: tweet.id!, success: { (tweet:Tweet) in
                print("Retweeted succssfully")
                self.tweet = tweet
                self.retweetCountsLabel.text = "\(tweet.retweetCount)"
                self.retweetImageView.setBackgroundImage(UIImage(named: "retweet_sel_ic.png"), for: UIControlState.normal)
                self.tweet.retweetCount = self.tweet.retweetCount + 1
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        }else{
            TwitterAPIClient.sharedInstance?.fetchTweetDetails(tweetId: tweet.originalTweetId!, success: { (tweet:Tweet) in
                TwitterAPIClient.sharedInstance?.deleteTweet(id: tweet.retweetId!, success: { (true) in
                    self.tweet = tweet
                    self.retweetCountsLabel.text = "\(tweet.retweetCount)"
                    self.retweetImageView.setBackgroundImage(UIImage(named: "retweet_ic.png"), for: UIControlState.normal)
                    self.tweet.didUserRetweet = false
                    self.tweet.retweetCount = self.tweet.retweetCount - 1
                }, failure: { (error: Error) in
                    print(error.localizedDescription)
                })
                
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        }
    }
    
    func unRetweet(){
    
    }
    @IBAction func onFavoriteClick(_ sender: Any) {
        if(tweet.didUserFavorites){
            
            TwitterAPIClient.sharedInstance?.unfavoriteTweet(id: tweet.id!, success: { (tweet:Tweet) in
                self.favoritesCountLabel.text = "\(tweet.favouritesCount)"
                self.tweet = tweet
                self.favoritesImageView.setBackgroundImage(UIImage(named:"favorite_ic.png"), for: UIControlState.normal)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })
        }else{
            TwitterAPIClient.sharedInstance?.favoriteTweet(id: tweet.id!, success: { (tweet:Tweet) in
                self.favoritesCountLabel.text = "\(tweet.favouritesCount)"
                self.tweet = tweet
                self.favoritesImageView.setBackgroundImage(UIImage(named:"favorite_sel_ic.png"), for: UIControlState.normal)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destination as! UINavigationController
        let destinationUIViewController = navigationController.topViewController as! AddNewTweetViewController
        destinationUIViewController.delegate = self
        destinationUIViewController.isReplyToTweet = true
        destinationUIViewController.replyTweet = tweet
    }
    
    func addNewTweetViewController(addNewTweetViewController: AddNewTweetViewController, getNewTweet tweet: Tweet) {
        print("Replied to tweet")
        self.replyImageView.setBackgroundImage(UIImage(named:"reply_sel_ic.png"), for: UIControlState.normal)
    }

}
