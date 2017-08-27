//
//  ItemProjectTableViewCell.swift
//  NVC
//
//  Created by lrussu on 6/25/17.
//  Copyright © 2017 lrussu. All rights reserved.
//

import UIKit

class ItemProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var itemProject: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
