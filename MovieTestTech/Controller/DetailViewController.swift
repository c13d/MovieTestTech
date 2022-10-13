//
//  DetailViewController.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 10/10/22.
//

import UIKit
import RxSwift
import youtube_ios_player_helper

class DetailViewController: UIViewController {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    @IBOutlet weak var voteAverage: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    @IBOutlet weak var ytPlayer: YTPlayerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let viewModel = ReviewViewModel()
    
    

    var movie: Movie? = nil
    
    private lazy var viewSpinner: UIView = {
        let view = UIView(frame: CGRect(
                            x: 0,
                            y: 0,
                            width: view.frame.size.width,
                            height: 100)
        )
        let spinner = UIActivityIndicatorView()
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    override func viewDidLayoutSubviews() {
        overview.sizeToFit()
    }
    
    func setupTableView(){
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.refreshControl = refreshControl
        
        tableViewBind()
        
        viewModel.isLoadingSpinnerAvaliable.subscribe { [weak self] isAvaliable in
            guard let isAvaliable = isAvaliable.element,
                  let self = self else { return }
            self.tableView.tableFooterView = isAvaliable ? self.viewSpinner : UIView(frame: .zero)
        }
        .disposed(by: disposeBag)
        
        viewModel.refreshControlCompelted.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
        .disposed(by: disposeBag)
        
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
            
        viewModel.refreshControlAction.onNext(())
    }
    private func tableViewBind() {
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: ReviewTableViewCell.self)){ index, movie, cell in
            cell.onBind(data: movie)
        }.disposed(by: disposeBag)

        tableView.rx.didScroll.subscribe { [weak self] _ in
            guard let self = self else { return }
            let offSetY = self.tableView.contentOffset.y
            let contentHeight = self.tableView.contentSize.height

            if offSetY > (contentHeight - self.tableView.frame.size.height - 100) {
                self.viewModel.fetchMoreDatas.onNext(())
            }
        }
        .disposed(by: disposeBag)

    }
    
    @objc private func refreshControlTriggered() {
        print("trigger refresh")
        viewModel.refreshControlAction.onNext(())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if(movie == nil){
            return
        }
        
        viewModel.movieId = movie!.id
        
        print("movie id \(viewModel.movieId)")
        
        title = movie!.title
        
        let genreViewModel = GenreViewModel.genreViewModel
        
        
        
        for g in movie!.genreIDS{
            let genreTxt =  genreViewModel.getGenreName(genreId: g)
            genre.text! += " \(genreTxt)"
            
            if(g != movie!.genreIDS.last){
                genre.text! += (",")
            }
        }
        
        
        releaseDate.text! += " \(movie!.releaseDate)"
        voteCount.text! += " \(movie!.voteCount)"
        voteAverage.text! += " \(movie!.voteAverage)"
        popularity.text! += " \(movie!.popularity)"
        overview.text! = movie!.overview
        
        var posterPath = ""
        if(movie?.posterPath != nil){
            posterPath = (movie?.posterPath)!
        }
        let result = MovieService().apiCallImage(posterPath: posterPath)
        
        switch result{
            case let .success(data):
            self.movieImage.image  = UIImage(data: data!)
            case let .failure(error):
                print(error)
        }
        
        let videoResult = MovieService().apiCallVideo(movieId: movie!.id)
        switch videoResult{
            case let .success(data):
            if(data?.results == nil){
                return
            }
            ytPlayer.load(withVideoId: (data?.results[0].key)!)
            case let .failure(error):
                print(error)
            
        }
        
        setupTableView()
        
        print("ini value \(viewModel.items.value)")
        
        
        
    }

}
