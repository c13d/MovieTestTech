//
//  SearchViewModel.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 11/10/22.
//

import Foundation
import RxCocoa
import RxSwift

final class SearchViewModel {
    
    private let disposeBag = DisposeBag()
    private let searchService = MovieService()

    let items = BehaviorRelay<[Search]>(value: [])

    let fetchMoreDatas = PublishSubject<Void>()
    let refreshControlAction = PublishSubject<Void>()
    let refreshControlCompelted = PublishSubject<Void>()
    let isLoadingSpinnerAvaliable = PublishSubject<Bool>()

    private var pageCounter = 1
    private var query = ""
    private var maxValue = 1
    private var isPaginationRequestStillResume = false
    private var isRefreshRequstStillResume = false
    
    init() {
        bind()
    }

    private func bind() {

        fetchMoreDatas.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.fetchDummyData(page: self.pageCounter,
                                isRefreshControl: false, query: self.query)
        }
        .disposed(by: disposeBag)

        refreshControlAction.subscribe { [weak self] _ in
            self?.refreshControlTriggered(query: self!.query)
        }
        .disposed(by: disposeBag)
    }

    private func fetchDummyData(page: Int, isRefreshControl: Bool, query: String) {
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
        
        // For your real service you have to handle fail status.
        searchService.fetchSearchDatas(query: self.query, page: page) { [weak self] searchResponse in
            self?.handleDummyData(data: searchResponse)
            self?.isLoadingSpinnerAvaliable.onNext(false)
            self?.isPaginationRequestStillResume = false
            self?.isRefreshRequstStillResume = false
            self?.refreshControlCompelted.onNext(())
        }
    }

    private func handleDummyData(data: SearchServiceResponse) {

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

    private func refreshControlTriggered(query: String) {
        isPaginationRequestStillResume = false
        pageCounter = 1
        self.query = query
        items.accept([])
        fetchDummyData(page: pageCounter,
                       isRefreshControl: true, query: self.query)
    }
    
    func setQuery(query: String){
        self.query = query
    }
}
