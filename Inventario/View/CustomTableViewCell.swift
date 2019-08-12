//
//  CustomTableViewCell.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 3/4/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var upLabel: UILabel!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var diaLabel: UILabel!
    @IBOutlet weak var mesLabel: UILabel!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
