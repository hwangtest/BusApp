//
//  customCell.swift
//  BusApp
//
//  Created by Hwang Lee on 11/29/16.
//  Copyright © 2016 Hwang Lee. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var nearestStopName: UILabel!
    @IBOutlet weak var times: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
