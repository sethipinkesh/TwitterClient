//
//  TwitterClient.swift
//  TwitterClient
//
//  Created by Sethi, Pinkesh on 4/15/17.
//  Copyright © 2017 Sethi, Pinkesh. All rights reserved.
//

import UIKit
import BDBOAuth1Manager


class TwitterAPIClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterAPIClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "k1hZEy6xAGaPvZqsHegMqwO47", consumerSecret: "HzZJWKD4NayvJ4vGJF2hgTWojy14HJDhrJ0Wk2KfIz5THpMWp7")
    var loginSuccess: (()->())?
    var loginFaliure: ((Error)->())?
    
    func login(success:@escaping ()->(), failure:@escaping (Error)->()){
        loginSuccess = success
        loginFaliure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string:"twitterDemo://oauth"), scope: nil, success:{ (requestToken: BDBOAuth1Credential?) -> Void in
            print("Rquest token is here \(requestToken!.token!)")
            
            let urlStringWithOuthToken = "https://api.twitter.com/oauth/authorize?oauth_token="+"\(requestToken!.token!)"
            let authorizeUrl = URL(string: urlStringWithOuthToken)
            print("Rquest token is here \(authorizeUrl!)")
            
            UIApplication.shared.open(authorizeUrl!, options: [:], completionHandler: nil)
        
            
        }) { (error: Error?) -> Void in
            print("Oops some error is fetching request token: \(error?.localizedDescription)")
            self.loginFaliure?(error!)
        }
    }

    func fetchHomeTimeLine(count:Int, success: @escaping ((_ tweets:[Tweet]) ->()), failure: @escaping ((Error) -> ())){
        get("1.1/statuses/home_timeline.json?count=\(count)", parameters:nil, success: { (urlSessionData:URLSessionDataTask, response:Any) in
            let responseDictionary = response as? [Dictionary<String, Any>]
            let tweets = Tweet.getTweetArray(tweetDictionaries: responseDictionary!)
            success(tweets)
        }, failure: { (urlSessionData:URLSessionDataTask?, error: Error?) in
            failure(error!)
        })
    }
    
    func fetchUserInfo(success: @escaping ((_ user:User) ->()), failure: @escaping ((Error) -> ())){
        get("1.1/account/verify_credentials.json", parameters: nil, success: { (task:URLSessionDataTask, reponse: Any) in
            print(reponse)
            let user  = User(userDataDictionary:reponse as! Dictionary<String, Any>)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error:Error?) in
            print(error?.localizedDescription ?? "Some error")
            failure(error!)
        })
    }
    
    func fetchTweetDetails(tweetId:String, success: @escaping ((_ tweet:Tweet) ->()), failure: @escaping ((Error) -> ())){
        let uriStr = "1.1/statuses/show/"+"\(tweetId)"+".json?include_my_retweet=1"
        get(uriStr, parameters:nil, success: { (urlSessionData:URLSessionDataTask, response:Any) in
            print(response)
            let tweet = Tweet(tweetDictionary: response as! [String: Any])
            success(tweet)
        }, failure: { (urlSessionData:URLSessionDataTask?, error: Error?) in
            failure(error!)
        })
    }
    
    func handleOpenUrl(url: URL){
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            print((requestToken?.token) ?? "")
            self.fetchUserInfo(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFaliure?(error)
            })
            
        }, failure: { (error:Error?) in
            print((error?.localizedDescription) ?? "Some error")
            self.loginFaliure?(error!)
        })

    }
    
    func sendTweet(text: String, success:@escaping ((_ tweet: Tweet) -> ()), failure: @escaping ((_ error:Error) -> ())) {
    post("1.1/statuses/update.json", parameters: ["status": text], constructingBodyWith: nil, success: {
    (operation: URLSessionDataTask, response: Any?) in
        
        let tweet = Tweet(tweetDictionary: response as! [String: Any])
        success(tweet)
        
    }, failure: { (operation: URLSessionDataTask?, error: Error) in
        print(error.localizedDescription)
        failure(error)
    })
    }
    
    func replyTweet(text: String, id:UInt64, success:@escaping ((_ tweet: Tweet) -> ()), failure: @escaping ((_ error:Error) -> ())) {
        post("1.1/statuses/update.json", parameters: ["status": text, "id":id], constructingBodyWith: nil, success: {
            (operation: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(tweetDictionary: response as! [String: Any])
            success(tweet)
            
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            failure(error)
        })
    }
    func deleteTweet(id: String, success:@escaping ((_ tweet: Tweet) -> ()), failure: @escaping ((_ error:Error) -> ())) {
        let uriStr = "1.1/statuses/destroy/"+"\(id)"+".json"
        post(uriStr, parameters: nil, constructingBodyWith: nil, success: {
            (operation: URLSessionDataTask, response: Any?) in
            print("\(response)")
            let tweet = Tweet(tweetDictionary: response as! [String: Any])
            success(tweet)
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            failure(error)
        })
    }
    
    func retweetTweet(id: UInt64, success:@escaping ((_ tweets:Tweet) ->()), failure: @escaping ((_ error:Error) -> ())) {
        
        post("1.1/statuses/retweet.json", parameters: ["id": id], success: {
            (operation: URLSessionDataTask, response: Any?) in
            print("\(response)")
            let tweet = Tweet(tweetDictionary: response as! [String: Any])
            success(tweet)
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            failure(error)
        })
    }
    
    func favoriteTweet(id: UInt64, success:@escaping ((_ tweets:Tweet) ->()), failure: @escaping ((_ error:Error) -> ())) {
        post("1.1/favorites/create.json", parameters: ["id": id], success: {
            (operation: URLSessionDataTask, response: Any?) in
            print("\(response)")
            let tweet = Tweet(tweetDictionary: response as! [String: Any])
            success(tweet)
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            failure(error)
        })
    }
    
    func unfavoriteTweet(id: UInt64, success:@escaping ((_ tweets:Tweet) ->()), failure: @escaping ((_ error:Error) -> ())) {
        post("1.1/favorites/destroy.json", parameters: ["id": id], success: {
            (operation: URLSessionDataTask, response: Any?) in
            print("\(response)")
            let tweet = Tweet(tweetDictionary: response as! [String: Any])
            success(tweet)
        }, failure: { (operation: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            failure(error)
        })
    }
    
    func logOut(){
        User.currentUser = nil
        deauthorize()
        
        // Post notification
        NotificationCenter.default.post(name: Notification.Name("UserDidLogoutNotification"), object: nil)
    }
}
