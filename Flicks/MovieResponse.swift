//
//  MovieResponse.swift
//  Flicks
//
//  Created by Rick Song on 2/6/16.
//  Copyright © 2016 Rick Song. All rights reserved.
//

import Foundation

struct MovieResponse {
    let title: String?
    let overview: String?
    let releaseDate: String?
    
    let posterPath: String?
    
    var posterUrl: String {
        return "https://image.tmdb.org/t/p/w342/\(self.posterPath!)"
    }
    
    var lowResPosterUrl: String {
        return "https://image.tmdb.org/t/p/w45/\(self.posterPath!)"
    }
    
    var highResPosterUrl: String {
        return "https://image.tmdb.org/t/p/original/\(self.posterPath!)"
    }
}
