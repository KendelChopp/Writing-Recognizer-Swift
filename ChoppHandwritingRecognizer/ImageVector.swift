//
//  ImageVector.swift
//  ChoppHandwritingRecognizer
//
//  Created by Kendel Chopp on 7/21/17.
//  Copyright © 2017 Kendel Chopp. All rights reserved.
//  http://kchopp.com
//

import Foundation

class ImageVector {
    var answer: [Double]! = Array(repeating: 0.0, count: 10)
    var pixels: [Double]!
    var singleAnswer: Int!
    
    init (value: [String]) {
        
        self.answer[Int(value[0])!] = 1.0
        self.singleAnswer = Int(value[0])
        self.pixels = [Double]()
       
        for i in 1...value.count - 1 {
            self.pixels.append(Double(value[i])! / 255.0)
        }
        self.pixels.append(1) //Bias
    }
}
