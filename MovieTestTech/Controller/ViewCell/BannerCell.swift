//
//  BannerCell.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 11/10/22.
//

import Foundation
import UIKit
class BannerCell: UICollectionViewCell {
    
    var data: Movie? {
        didSet{
            guard let data = data else { return }
            
            var posterPath = ""
            if(data.posterPath != nil){
                posterPath = data.posterPath!
            }
            let result = MovieService().apiCallImage(posterPath: posterPath)
            
            switch result{
                case let .success(data):
                self.image.image  = UIImage(data: data!)
                case let .failure(error):
                    print(error)
            }
            
        }
    }
    
    fileprivate let image: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        
        return iv
        
    }()
    
    override init(frame: CGRect){
        super.init(frame: .zero)
        
        contentView.addSubview(image)
        image.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
