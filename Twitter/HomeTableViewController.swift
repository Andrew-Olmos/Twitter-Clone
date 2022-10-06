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
    
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("1")
        numOfTweets = 20
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 150
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadTweets()
    }
    
    
    @objc func loadTweets(){
        
        numOfTweets = 20
        
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success:
        { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            print(self.tweetArray)
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweet\(Error)")
        })
    }
    
    
    func loadMoreTweets(){
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numOfTweets = numOfTweets + 20
        let myParams = ["count": numOfTweets]
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count{
            loadMoreTweets()
        }
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
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        
        
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
