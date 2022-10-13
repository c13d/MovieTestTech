//
//  TableViewCell.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 10/10/22.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var movieDescription: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    
    var data:Movie?
    var data2:Search?
    var data3:Review?
    let genreViewModel = GenreViewModel.genreViewModel
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func onBind(data: Review){
        self.data3 = data
        
        movieTitle.text = data.author
        movieDescription.text = data.content
        
    }
    
    func onBind(data: Movie){
        self.data = data
        
        movieTitle.text = data.title
        movieDescription.text = "Genre: "
        for genre in data.genreIDS{
            movieDescription.text! += " \(genreViewModel.getGenreName(genreId: genre))"
            if(genre != data.genreIDS.last){
                movieDescription.text! += ","
            }
        }
        
        var posterPath = ""
        if(data.posterPath != nil){
            posterPath = data.posterPath!
        }
        let result = MovieService().apiCallImage(posterPath: posterPath)
        
        switch result{
            case let .success(data):
            self.movieImage.image  = UIImage(data: data!)
            case let .failure(error):
                print(error)
        }
    }
    
    func onBind(data: Search){
        
        let id = String(data.id)
        var movieDetail = MovieService().apiCallDetail(movieId: id )
        
//        if(movieDetail == nil){
//            return
//        }
        
//        print("Ke Fetch \(movieDetail!.id)")
//
        movieTitle.text = data.name
        movieDescription.text = data.originCountry
        var posterPath = ""
        if(data.logoPath != nil){
            posterPath = "\(data.logoPath!)"
            print("posterPath = \(posterPath)")
        }
        let result = MovieService().apiCallImage(posterPath: posterPath)
        
        switch result{
            case let .success(data):
            self.movieImage.image  = UIImage(data: data!)
            case let .failure(error):
                print(error)
        }
        
    }

    
}
