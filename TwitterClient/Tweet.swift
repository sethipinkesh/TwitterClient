//
//  Tweet.swift
//  TwitterClient
//
//  Created by Sethi, Pinkesh on 4/15/17.
//  Copyright © 2017 Sethi, Pinkesh. All rights reserved.
//

import UIKit

class Tweet: NSObject {

    var text: String?
    var senderName: String?
    var senderScreenName: String?
    var senderProfileImageUrl: URL?
    var retweetCount: Int = 0
    var favouritesCount: Int = 0
    var replyCount: Int = 0
    var timeStamp: Date?
    var id: UInt64?
    var idStr: String?
    var retweetUserName: String?
    var retweetScreenName: String?
    var didUserRetweet: Bool
    var didUserFavorites: Bool
    
    var originalTweetId: String?
    var retweetId: String?
    
    init(tweetDictionary: Dictionary<String, Any>) {
        print(tweetDictionary)
        
        id = tweetDictionary["id"] as? UInt64
        text = tweetDictionary["text"] as? String
        idStr = tweetDictionary["id_str"] as? String
        
        retweetCount = (tweetDictionary["retweet_count"] as? Int) ?? 0
        favouritesCount = (tweetDictionary["favorite_count"] as? Int) ?? 0
        
        
        let retweetedStatus = tweetDictionary["retweeted_status"] as? Dictionary<String,Any>
        if let retweetedStatus = retweetedStatus{
            originalTweetId = retweetedStatus["id_str"] as! String?
        }else{
            originalTweetId = idStr
        }
        
        let currentUserRetweet = tweetDictionary["current_user_retweet"] as? Dictionary<String,Any>
        if let currentUserRetweet = currentUserRetweet{
            retweetId = currentUserRetweet["id_str"] as! String?
        }
        
        let timeStampStr = tweetDictionary["created_at"] as? String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y "
        
        if let timeStampStr = timeStampStr{
            timeStamp = dateFormatter.date(from: timeStampStr)
        }
        
        let userDictionary = tweetDictionary["user"] as? Dictionary<String, Any>
        senderName = userDictionary?["name"] as? String
        senderScreenName = "@"+(userDictionary?["screen_name"] as? String)!
        
        let urlString = userDictionary?["profile_image_url_https"] as? String
        if let urlStr = urlString{
            senderProfileImageUrl = URL(string: urlStr)
        }
        
        didUserRetweet = tweetDictionary["retweeted"] as? Bool ?? false
        didUserFavorites = tweetDictionary["favorited"] as? Bool ?? false
        
        let retweetStatusDictionary = tweetDictionary["retweeted_status"] as? NSDictionary
        if retweetStatusDictionary != nil {
            let retweetUser = retweetStatusDictionary?["user"] as? NSDictionary
            retweetUserName = retweetUser?["screen_name"] as? String
            retweetScreenName = retweetUser?["name"] as? String
            print(retweetScreenName ?? "")
            print(retweetUserName ?? "")
        }
    }
    
    class func getTweetArray(tweetDictionaries:[Dictionary<String, Any>]) -> [Tweet]{
        var tweetsArray = [Tweet]()
        
        for tweetDictionary in tweetDictionaries{
            let tweet = Tweet(tweetDictionary:tweetDictionary)
            tweetsArray.append(tweet)
        }
        return tweetsArray
    }
    
    class func getTimeLable(date: Date){
        // *** Create date ***
        let date = date
        
        // *** create calendar object ***
        var calendar = NSCalendar.current
        
        // *** Get components using current Local & Timezone ***
        print(calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date))
        
        // *** define calendar components to use as well Timezone to UTC ***
        let unitFlags = Set<Calendar.Component>([.hour, .year, .minute])
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        // *** Get All components from date ***
        let components = calendar.dateComponents(unitFlags, from: date as Date)
        print("All Components : \(components)")
        
        // *** Get Individual components from date ***
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let seconds = calendar.component(.second, from: date as Date)
        print("\(hour):\(minutes):\(seconds)")
    }
    
    class func getTimeDifference(currentDate: Date, oldDate: Date) -> String{
        let interval: TimeInterval = currentDate.timeIntervalSince(oldDate)
        let intervalMS = Int(interval)
        
        let hours = intervalMS / (60 * 60)
        let remainder = intervalMS % 3600
        let minutes = remainder / 60
        let seconds = remainder % 60
        
        if hours < 1 {
            if(minutes<1){
                return "\(seconds)s"
            }else{
                return "\(minutes)m"
            }
        } else if hours < 24 && hours >= 1 {
            return "\(hours)h"
        } else {
            let days = Int(interval) / 86400
            return "\(days)d"
        }
    
    }
    
}
