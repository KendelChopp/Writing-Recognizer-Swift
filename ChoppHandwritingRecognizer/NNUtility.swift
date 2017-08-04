//
//  NNUtility.swift
//  ChoppHandwritingRecognizer
//
//  Created by Kendel Chopp on 7/26/17.
//  Copyright © 2017 Kendel Chopp. All rights reserved.
//  http://kchopp.com
//

import Foundation
import Cocoa

class NNUtility {
    public static func sigmoid(z: Double) -> Double{
        return 1.0 / (1.0 + pow(M_E, -z))
    }
    public static func transpose<T>(input: [[T]]) -> [[T]] {
        if input.isEmpty { return [[T]]() }
        let count = input[0].count
        var out = [[T]](repeating: [T](), count: count)
        for outer in input {
            for (index, inner) in outer.enumerated() {
                out[index].append(inner)
            }
        }
        
        return out
    }
    
    public static func getAnswer(outputs: [Double]) -> Int {
        var index = 0
        var max = outputs[0]
        var secondMax = 0.0
        for i in 1...outputs.count - 1 {
            if (outputs[i] > max) {
                secondMax = max
                max = outputs[i]
                index = i
            }
        }
        if secondMax >= 0.5  || max < 0.5 {
            return -1
        }
        return index
    }
    
    public static func saveWeights(weights: [[[Double]]]) {
        for layer in 1...weights.count {
            let fileName = "weights\(layer).csv"
            
            //Replace SAVE_LOCATION with the desired destination
            let location = "SAVE_LOCATION" + fileName

            
            let fileUrl = URL(fileURLWithPath: location)
            var text = ""
            for i in 1...weights[layer-1].count {
                let count = weights[layer-1][i-1].count
                for j in 1...count - 1 {
                    text = text + String(weights[layer-1][i-1][j-1]) + ","
                }
                text = text + String(weights[layer-1][i-1][count - 1]) + "\n"
            }
            
            do {
                try text.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
        }
        
        
    }

}

extension Double {
    private static let arc4randomMax = Double(UInt32.max)
    
    static func random0to1() -> Double {
        return Double(arc4random()) / arc4randomMax
    }
}


