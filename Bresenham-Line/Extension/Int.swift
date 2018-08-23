//
//  Int.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-18.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Foundation

extension Int {

    func sign() -> Int {
        if self > 0         { return  1 }
        else if self < 0    { return -1 }
        else                { return  0 }
    }
    
}
