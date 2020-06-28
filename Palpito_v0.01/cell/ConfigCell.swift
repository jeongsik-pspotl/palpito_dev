//
//  ConfigCell.swift
//  Palpito
//
//  Created by 김정식 on 2020/05/23.
//  Copyright © 2020 김정식. All rights reserved.
//

import UIKit

class ConfigCell: UITableViewCell {


    @IBOutlet weak var arrowRight: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        icon.contentMode = .scaleAspectFit
        title.font = UIFont.systemFont(ofSize: 12.0)
        arrowRight.image = UIImage(named: "arrow_right")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //print("selected title : \(String(describing: self.title.text))")

        // Configure the view for the selected state
    }
    
}
