//
//  MyCollectionViewCell.swift
//  therealnft
//
//  Created by Macbook on 30/08/21.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    
//    @IBOutlet var nte:UILabel!

    @IBOutlet weak var cellview: UIView!
    
    @IBOutlet weak var cell_descc: UILabel!
    @IBOutlet weak var cell_title: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellview.layer.cornerRadius = 10.0
//        cellview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        img.layer.cornerRadius = 10.0
        img.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Initialization code
    }

}
