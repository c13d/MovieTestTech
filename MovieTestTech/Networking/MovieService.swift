//
//  MovieService.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 11/10/22.
//

import Foundation

enum NetworkError: Error {
    case url
    case server
}

struct MovieService {
    
    func apiCallSearch(query:String, page: Int) -> Result<SearchResult?, NetworkError> {
        print("ini query \(query)")
        
        var result: Result<SearchResult?, NetworkError>!
        
        if(query == "" || query.count < 3){
            result = .failure(.server)
            return result
        }
        
        let path = "https://api.themoviedb.org/3/search/company?api_key=6c489b7a4ed215ea82009dbe1ea15061&query=\(query)&page=\(page)"
        
        print("page \(page)")
        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                var searchResult:SearchResult?
                do{
                    searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                    result = .success(searchResult)
                }catch{
                    result = .failure(.server)
                }
            } else {
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        print("Selesai")
       
        return result
    }
    
    func apiCallReview(page:Int, movieId: Int) -> Result<ReviewResult?, NetworkError>{
        let path = "https://api.themoviedb.org/3/movie/\(movieId)/reviews?api_key=6c489b7a4ed215ea82009dbe1ea15061&language=en-US&page=1"
        print("review path \(path)")
        
        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        var result: Result<ReviewResult?, NetworkError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { (data, req, error) in
            if let data = data {
                var genreResult:ReviewResult?
                do{
                    genreResult = try JSONDecoder().decode(ReviewResult.self, from: data)
                    result = .success(genreResult)
                }catch{
                    result = .failure(.server)
                }
            } else {
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func apiCallVideo(movieId: Int) -> Result<VideoResult?, NetworkError>{
        let path = "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=6c489b7a4ed215ea82009dbe1ea15061&language=en-US"
        
        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        var result: Result<VideoResult?, NetworkError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { (data, req, error) in
            if let data = data {
                var genreResult:VideoResult?
                do{
                    genreResult = try JSONDecoder().decode(VideoResult.self, from: data)
                    result = .success(genreResult)
                }catch{
                    result = .failure(.server)
                }
            } else {
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func apiCallGenre() -> Result<GenreResult?, NetworkError>{
        let path = "https://api.themoviedb.org/3/genre/movie/list?api_key=6c489b7a4ed215ea82009dbe1ea15061&language=en-US"
        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        var result: Result<GenreResult?, NetworkError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { (data, req, error) in
            if let data = data {
                var genreResult:GenreResult?
                do{
                    genreResult = try JSONDecoder().decode(GenreResult.self, from: data)
                    result = .success(genreResult)
                }catch{
                    result = .failure(.server)
                }
            } else {
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    func apiCallImage(posterPath: String) -> Result<Data?, NetworkError>{
        let path = "https://image.tmdb.org/t/p/w342/\(String(describing: posterPath))"
        //print("path \(path)")
        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        var result: Result<Data?, NetworkError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { (data, req, error) in
            if let data = data {
                let imageData: Data?
                do{
                    imageData = try data
                    result = .success(imageData!)
                }catch{
                    result = .failure(.server)
                }
                
            } else {
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        //print("Selesai Cell")
        
        return result
    }
    
    func apiCallDetail(movieId: String) -> Detail?{
        let path = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=6c489b7a4ed215ea82009dbe1ea15061"
        print("path = \(path)")
        let url = URL(string: path)!
        let semaphore = DispatchSemaphore(value: 0)
        var movieDetail:Detail?
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            if let data = data {
                
                do{
                    movieDetail = try JSONDecoder().decode(Detail.self, from: data)
                }catch{
                    
                }
                
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return movieDetail
    }
    
    func apiCallTopRated() -> TopRated{
        let path = "https://api.themoviedb.org/3/movie/top_rated?api_key=6c489b7a4ed215ea82009dbe1ea15061&language=en-US&page=1"

        let url = URL(string: path)!
        let semaphore = DispatchSemaphore(value: 0)
        var movieResult:TopRated?
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            if let data = data {
                
                do{
                    movieResult = try JSONDecoder().decode(TopRated.self, from: data)
                }catch{
                    
                }
                
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return movieResult!
    }
    
    
    func apiCallUpcoming(page: Int) -> Result<MovieResult?, NetworkError> {
        let path = "https://api.themoviedb.org/3/movie/upcoming?api_key=6c489b7a4ed215ea82009dbe1ea15061&language=en-US&page=\(page)"
        
        print("page \(page)")
        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        var result: Result<MovieResult?, NetworkError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                var movieResult:MovieResult?
                do{
                    movieResult = try JSONDecoder().decode(MovieResult.self, from: data)
                    result = .success(movieResult)
                }catch{
                    result = .failure(.server)
                }
                
            } else {
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        print("Selesai")
       
        return result
    }
    
    func fetchSearchDatas(query:String, page: Int, completion: @escaping (SearchServiceResponse) -> ()) {
        
        if(query == ""){
            return
        }
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.apiCallSearch(query: query, page: page)
            switch result{
            case let .success(data):
                let maxPage =  data!.totalPages
                if page > maxPage {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        completion(SearchServiceResponse(maxPage: maxPage,
                                                        datas: nil))
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        completion(SearchServiceResponse(maxPage: maxPage,
                                                        datas: data?.results))
                    }
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func fetchUpcomingDatas(page: Int, completion: @escaping (MovieServiceResponse) -> ()) {
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.apiCallUpcoming(page: page)
            switch result{
            case let .success(data):
                let maxPage =  data!.totalPages
                if page > maxPage {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        completion(MovieServiceResponse(maxPage: maxPage,
                                                        datas: nil))
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        completion(MovieServiceResponse(maxPage: maxPage,
                                                        datas: data?.results))
                    }
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func fetchReviewDatas(id:Int ,page: Int, completion: @escaping (ReviewServiceResponse) -> ()) {
        
        DispatchQueue.global(qos: .utility).async {
            let result = self.apiCallReview(page: page, movieId: id)
            switch result{
            case let .success(data):
                let maxPage =  data!.totalPages
                if page > maxPage {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        completion(ReviewServiceResponse(maxPage: maxPage,
                                                        datas: nil))
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        completion(ReviewServiceResponse(maxPage: maxPage,
                                                        datas: data?.results))
                    }
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
}
