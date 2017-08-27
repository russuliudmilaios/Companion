 //
//  TableViewCell.swift
//  NVC
//
//  Created by lrussu on 6/8/17.
//  Copyright © 2017 lrussu. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var userpic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var wallet: UILabel!
    @IBOutlet weak var correction: UILabel!
    @IBOutlet weak var level: UIProgressView!
    
    @IBOutlet weak var levellable: UILabel!
 
    
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
