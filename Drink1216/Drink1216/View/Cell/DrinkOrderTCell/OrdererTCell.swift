//
//  OrdererTableViewCell.swift
//  Drink1216
//
//  Created by change on 2021/12/24.
//

import UIKit

class OrdererTCell: UITableViewCell {

    @IBOutlet weak var ordererLabel: UILabel!
    @IBOutlet weak var ordererNameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
