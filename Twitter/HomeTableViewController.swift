//
//  HomeTableViewController.swift
//  HomeTableViewController
//
//  Created by Andrew Olmos on 9/28/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numOfTweets: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("1")
        loadTweet()
    }
    
    
    func loadTweet(){
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": 10]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success:
        { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            print(self.tweetArray)
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("Could not retrieve tweet\(Error)")
        })
    }
    
    
    @IBAction func onLogOut(_ sender: Any) {
        TwitterAPICaller.client?.logout() // logs out in the background but nothing shows on screen
        self.dismiss(animated: true, completion: nil)
        
        
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetsCell", for: indexPath) as! TweetsCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as! String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as! String
        
        let imageURL = URL(string: ((user["profile_image_url_https"] as? String)!))
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

}
