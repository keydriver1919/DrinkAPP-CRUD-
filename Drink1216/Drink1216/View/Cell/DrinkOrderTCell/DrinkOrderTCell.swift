//
//  DrinkOrderTableViewCell.swift
//  Drink1216
//
//  Created by change on 2021/12/24.
//

import UIKit

class DrinkOrderTCell: UITableViewCell {

    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var addPriceLabel: UILabel!
    @IBOutlet weak var addFeedPriceLabel: UILabel!
    @IBOutlet weak var radioButtonImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
