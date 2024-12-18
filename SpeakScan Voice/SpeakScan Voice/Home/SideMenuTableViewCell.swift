//
//  SideMenuTableViewCell.swift
//  Flip & Bet
//
//  Created by Moin Janjua on 12/08/2024.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var sMenuImgs: UIImageView!
    @IBOutlet weak var sidemenu_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
