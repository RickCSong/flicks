//
//  ViewController.swift
//  Flicks
//
//  Created by Rick Song on 2/6/16.
//  Copyright © 2016 Rick Song. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var moviesEndpoint: String!
    var moviesApiKey: String = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    var movieResponses: [MovieResponse]?
    var filteredMovieResponses: [MovieResponse]?
    
    var numPages: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        self.moviesSearchBar.delegate = self
        
        loadMovieResponses()
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "loadMovieResponses:", forControlEvents: UIControlEvents.ValueChanged)
        self.moviesTableView.insertSubview(refreshControl, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.moviesTableView.indexPathForCell(sender as! UITableViewCell)
        let movieResponse = self.filteredMovieResponses![indexPath!.row]
        let movieDetailViewController = segue.destinationViewController as! MovieDetailViewController
        
        movieDetailViewController.movieResponse = movieResponse
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.ricksong.MovieTableViewCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movieResponse = self.filteredMovieResponses![indexPath.row]
        
        // Set cell data
        cell.titleLabel.text = movieResponse.title
        cell.overviewLabel.text = movieResponse.overview
        cell.posterImageView.setImageWithURL(NSURL(string: movieResponse.posterUrl)!)
        
        // Set cell selection style
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 197/255, green: 239/255, blue: 247/255, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredMovieResponses?.count ?? 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Don't show the gray background on tap
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let canFilterResponses = searchText.isEmpty && self.movieResponses != nil
        
        // This method updates filteredMovieResponses based on the text in the Search Box
        self.filteredMovieResponses = canFilterResponses ? self.movieResponses : self.movieResponses?.filter({
                movieResponse in movieResponse.title?.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
        
        // Refresh the movies table
        self.moviesTableView.reloadData()
    }
    
    // Load data from The Movie DB
    func loadMovieResponses(refreshControl: UIRefreshControl? = nil) {
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(self.moviesEndpoint)?api_key=\(self.moviesApiKey)")
        let request = NSURLRequest(URL: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        if refreshControl == nil {
            // Display HUD right before the request is made
            // if there is no refreshControl passed in
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                guard error == nil else {
                    self.networkErrorView.hidden = false
                    
                    if let refreshControl = refreshControl {
                        // Tell the refreshControl to stop spinning if refreshControl is passed in
                        refreshControl.endRefreshing()
                    } else {
                        // Otherwise, hide the HUD (must be done on main UI thread)
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                    return
                }
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.numPages = responseDictionary["total_pages"] as? Int
                            self.movieResponses = (responseDictionary["results"] as? [NSDictionary])?.map( { response in
                                return MovieResponse(
                                    title: response["title"] as? String,
                                    overview: response["overview"] as? String,
                                    releaseDate: response["release_date"] as? String,
                                    posterPath: response["poster_path"] as? String
                                )
                            } )
                            self.filteredMovieResponses = self.movieResponses
                            
                            if let refreshControl = refreshControl {
                                // Tell the refreshControl to stop spinning if refreshControl is passed in
                                refreshControl.endRefreshing()
                            } else {
                                // Otherwise, hide the HUD (must be done on main UI thread)
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                            }
                            
                            // Refresh the movies table
                            self.moviesTableView.reloadData()
                    }
                }
        });
        task.resume()
    }
}

