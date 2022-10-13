//
//  GenreViewModel.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 12/10/22.
//

import Foundation


final class GenreViewModel{
    
    //singleton
    static let genreViewModel = GenreViewModel()
    
    var genreList:[Genre]?
    var genreListString:[String] = []
    
    private init(){
        fetchGenres()
        setGenreString()
    }
    
    private func fetchGenres(){
        let genre = MovieService().apiCallGenre()
        switch genre{
        case let .success(data):
            genreList = data!.genres
            
        case let .failure(data):
            print("error")
        }
    }
    
    private func setGenreString(){
        for genre in genreList!{
            genreListString.append(genre.name)
        }
    }
    
    func getGenreName(genreId: Int) -> String{
        for genre in genreList!{
            if(genre.id == genreId){
                return genre.name
                
            }
        }
        
        return ""
    }
    
    func getGenreId(genreName: String) -> Int{
        for genre in genreList!{
            if(genre.name == genreName){
                return genre.id
            }
        }
        return 0
    }
    
    
    
}
