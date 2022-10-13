//
//  MovieViewModel.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 11/10/22.
//

import Foundation

import Foundation
import RxCocoa
import RxSwift

final class MovieViewModel {
    
    private let disposeBag = DisposeBag()
    private let movieService = MovieService()

    let movies = BehaviorRelay<[Movie]>(value: [])

    let fetchMoreDatas = PublishSubject<Void>()
    let refreshControlAction = PublishSubject<Void>()
    let refreshControlCompelted = PublishSubject<Void>()
    let isLoadingSpinnerAvaliable = PublishSubject<Bool>()
    
    var genreId: Int = 28

    private var pageCounter = 1
    private var maxValue = 1
    private var isPaginationRequestStillResume = false
    private var isRefreshRequstStillResume = false
    
    init() {
        bind()
    }

    private func bind() {

        fetchMoreDatas.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.fetchMovieData(page: self.pageCounter,
                                isRefreshControl: false)
        }
        .disposed(by: disposeBag)

        refreshControlAction.subscribe { [weak self] _ in
            self?.refreshControlTriggered()
        }
        .disposed(by: disposeBag)
    }

    private func fetchMovieData(page: Int, isRefreshControl: Bool) {
        if isPaginationRequestStillResume || isRefreshRequstStillResume { return }
        self.isRefreshRequstStillResume = isRefreshControl
        
        if pageCounter > maxValue  {
            isPaginationRequestStillResume = false
            return
        }
       
        isPaginationRequestStillResume = true
        isLoadingSpinnerAvaliable.onNext(true)
        
        if pageCounter == 1  || isRefreshControl {
            isLoadingSpinnerAvaliable.onNext(false)
        }
        
        movieService.fetchUpcomingDatas(page: page) { [weak self] movieResponse in
            self?.handleMovieData(data: movieResponse, genreId: self!.genreId)
            self?.isLoadingSpinnerAvaliable.onNext(false)
            self?.isPaginationRequestStillResume = false
            self?.isRefreshRequstStillResume = false
            self?.refreshControlCompelted.onNext(())
        }
    }

    private func handleMovieData(data: MovieServiceResponse, genreId: Int) {
        
        guard let filteredMovie = data.datas?.filter({ movie in
            var find = false
            
            for genre in movie.genreIDS{
                if(genre == genreId){
                    find = true
                }
            }
            
            return find
        })else{
            return
        }

        maxValue = data.maxPage
        if pageCounter == 1{
            self.maxValue = data.maxPage
            movies.accept(filteredMovie)
        } else {
            let oldDatas = movies.value
            movies.accept(oldDatas + filteredMovie)
        }
        pageCounter += 1
    }

    private func refreshControlTriggered() {
        isPaginationRequestStillResume = false
        pageCounter = 1
        movies.accept([])
        fetchMovieData(page: pageCounter,
                       isRefreshControl: true)
    }
}
