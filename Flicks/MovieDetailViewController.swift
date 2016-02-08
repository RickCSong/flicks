//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Rick Song on 2/6/16.
//  Copyright © 2016 Rick Song. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var movieResponse: MovieResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.movieResponse!.title
        self.overviewLabel.text = self.movieResponse!.overview
        
        // Set the background image with low resolution first followed by high resolution
        let lowResImageRequest = NSURLRequest(URL: NSURL(string: self.movieResponse!.lowResPosterUrl)!)
        let highResImageRequest = NSURLRequest(URL: NSURL(string: self.movieResponse!.highResPosterUrl)!)
        self.posterImageView.setImageWithURLRequest(
            lowResImageRequest,
            placeholderImage: nil,
            success: { (lowResImageRequest, lowResImageResponse, lowResImage) -> Void in
                
                // lowResImageRequest will be nil if the lowResImage is already available
                // in cache (might want to do something smarter in that case).
                self.posterImageView.alpha = 0.0
                self.posterImageView.image = lowResImage;
                
                UIView.animateWithDuration(0.6, animations: { () -> Void in
                    
                    self.posterImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterImageView.setImageWithURLRequest(
                            highResImageRequest,
                            placeholderImage: lowResImage,
                            success: { (largeImageRequest, largeImageResponse, highResImage) -> Void in
                                
                                self.posterImageView.image = highResImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
        
        
        // Autosize the overview label
        self.overviewLabel.sizeToFit()
        
        // Set the details view sizing
        let detailsViewWidth = self.detailsView.bounds.width
        let detailsViewHeight = self.overviewLabel.bounds.height + self.titleLabel.bounds.height + 60
        self.detailsView.frame = CGRectMake(18, 420, detailsViewWidth, detailsViewHeight)
        
        // Set the scroll view sizing
        let detailsScrollingViewWidth = self.detailsScrollView.bounds.width
        let detailsScrollingViewHeight = self.detailsView.bounds.height + 460
        self.detailsScrollView.contentSize = CGSizeMake(detailsScrollingViewWidth, detailsScrollingViewHeight)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
