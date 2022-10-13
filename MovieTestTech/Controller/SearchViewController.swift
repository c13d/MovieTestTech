//
//  SearchViewController.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 11/10/22.
//

// 

import RxCocoa
import RxSwift
import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate{
    
    private let searchVC = UISearchController(searchResultsController: nil)
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        return tableView
    }()
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.viewModel.fetchMoreDatas.onNext(())
        }
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
        
        
        createSearchBar()
    }
    
    private func bind() {
        
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
    }
    
    private func tableViewBind() {

        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)){ index, movie, cell in
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
    
    private func layout() {

        view.backgroundColor = .white

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
    }
    
    private func createSearchBar(){
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }

    // Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else{
            return
        }
        
        print(text)
        
        if(text == "" || text.count < 3){
            return
        }
        
        viewModel.setQuery(query: text)
        refreshControlTriggered()
    }
}

extension SearchViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
