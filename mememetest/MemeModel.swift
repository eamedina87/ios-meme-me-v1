//
//  MemeModel.swift
//  mememetest
//
//  Created by Erick Medina on 17/8/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText : String?
    var bottomText : String?
    var originalImage : UIImage?
    var memedImage : UIImage?
    
    init(topText:String, bottomText:String, originalImage: UIImage, memedImage: UIImage){
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
    
}
