//
//  ViewController.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 10/10/22.
//  API key 6c489b7a4ed215ea82009dbe1ea15061 https:api.themoviedb.org/3/movie/upcoming?api_key=6c489b7a4ed215ea82009dbe1ea15061&language=en-US&page=1

// https://api.themoviedb.org/3/movie/top_rated?api_key=6c489b7a4ed215ea82009dbe1ea15061&language=en-US&page=1


import UIKit
import RxSwift
import RxCocoa
import DropDown

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    private var selectedMovie:Movie? = nil
    
    private var isSelectedTop = false
    
    private let topRated = MovieService().apiCallTopRated().results
    private let viewModel = MovieViewModel()
    private let genreViewModel = GenreViewModel.genreViewModel
    private let dropDown = DropDown()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewCV: UIView!
    
    @IBOutlet weak var viewDropDown: UIView!
    @IBOutlet weak var lableSelectedDropDown: UILabel!
    
    @IBAction func showGenreOption(_ sender: Any) {
        dropDown.show()
    }
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
    
    func setupDropDown(){
        lableSelectedDropDown.layer.borderWidth = 1
        
        dropDown.anchorView = viewDropDown

        dropDown.dataSource = genreViewModel.genreListString ?? [""]
        
        self.lableSelectedDropDown.text = " Select Genre"
        
        // Top of drop down will be below the anchorView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        // When drop down is displayed with `Direction.top`, it will be above the anchorView
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        
        DropDown.appearance().cornerRadius = 10
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            self.lableSelectedDropDown.text = " \(dropDown.dataSource[index])"
            viewModel.genreId = genreViewModel.genreList![index].id
            
            viewModel.refreshControlAction.onNext(())
        }
    }
    
    func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(BannerCell.self
                                , forCellWithReuseIdentifier: "cell")
        
        collectionView.backgroundColor = .white
        collectionView.topAnchor.constraint(equalTo: viewCV.topAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: viewCV.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: viewCV.trailingAnchor, constant: 0).isActive = true
        collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.5).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropDown()
        
        view.addSubview(collectionView)
        setupCollectionView()
        
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
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
        viewModel.movies.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)){ index, movie, cell in
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
        
        tableView.rx.modelSelected(Movie.self).subscribe(onNext: { [weak self] movie in
            self!.selectedMovie = movie.self
            self!.isSelectedTop = false
            self!.performSegue(withIdentifier: "goToDetail", sender: self)
        } ).disposed(by: self.disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            
            let destinationVC = segue.destination as? DetailViewController
        
            destinationVC?.movie = self.selectedMovie
                
        
        }
    }
    
    @objc private func refreshControlTriggered() {
        print("trigger refresh")
        viewModel.refreshControlAction.onNext(())
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topRated.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BannerCell
        cell.data = self.topRated[indexPath.row]
        print("index \(indexPath.row)")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.isSelectedTop = true
        self.selectedMovie = topRated[indexPath.row]
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }

    
}



