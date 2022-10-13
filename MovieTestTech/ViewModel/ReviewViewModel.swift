//
//  ReviewViewModel.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 13/10/22.
//
import Foundation

import Foundation
import RxCocoa
import RxSwift

final class ReviewViewModel {
    
    private let disposeBag = DisposeBag()
    private let movieService = MovieService()

    let items = BehaviorRelay<[Review]>(value: [])

    let fetchMoreDatas = PublishSubject<Void>()
    let refreshControlAction = PublishSubject<Void>()
    let refreshControlCompelted = PublishSubject<Void>()
    let isLoadingSpinnerAvaliable = PublishSubject<Bool>()

    var movieId: Int = 28
    
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
        
        movieService.fetchReviewDatas( id: movieId, page: page) { [weak self] reviewResponse in
            self?.handleMovieData(data: reviewResponse)
            self?.isLoadingSpinnerAvaliable.onNext(false)
            self?.isPaginationRequestStillResume = false
            self?.isRefreshRequstStillResume = false
            self?.refreshControlCompelted.onNext(())
        }
    }

    private func handleMovieData(data: ReviewServiceResponse) {

        maxValue = data.maxPage
        if pageCounter == 1, let finalData = data.datas {
            self.maxValue = data.maxPage
            items.accept(finalData)
        } else if let data = data.datas {
            let oldDatas = items.value
            items.accept(oldDatas + data)
        }
        pageCounter += 1
    }

    private func refreshControlTriggered() {
        isPaginationRequestStillResume = false
        pageCounter = 1
        items.accept([])
        fetchMovieData(page: pageCounter,
                       isRefreshControl: true)
    }
}
