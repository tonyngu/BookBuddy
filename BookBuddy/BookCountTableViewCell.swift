//
//  BookCountTableViewCell.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 9/6/2023.
//

import UIKit

class BookCountTableViewCell: UITableViewCell {

    @IBOutlet weak var totalLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
