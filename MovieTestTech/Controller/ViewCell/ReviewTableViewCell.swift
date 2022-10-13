//
//  ReviewTableViewCell.swift
//  MovieTestTech
//
//  Created by Christophorus Davin on 13/10/22.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var review: UILabel!
    
    var data:Review?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onBind(data: Review){
        self.data = data
        
        author.text = data.author
        review.text = data.content
        
    }
    
    
}
