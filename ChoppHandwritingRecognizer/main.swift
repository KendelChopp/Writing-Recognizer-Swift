//
//  main.swift
//  ChoppHandwritingRecognizer
//
//  Created by Kendel Chopp on 7/21/17.
//  Copyright © 2017 Kendel Chopp. All rights reserved.
//  http://kchopp.com
//
//  Training data is provided by Kaggle and MNIST
//  Data can be found at https://www.kaggle.com/c/digit-recognizer/data
//

import Foundation
import Cocoa


//Initial learning rate
var learningRate = 0.1

//Create a network with one hidden layer
var weights = Array(repeating: Array(repeating: Array(repeating: Double(0), count: 1), count: 1), count: 2)

/*
    Input layer: 784 nodes + a bias
    Hidden layer: 15 nodes + a bias
    Output layer: 10 nodes (0-9)
*/
weights[0] = Array(repeating: Array(repeating: 0.0, count: 785), count: 15)
weights[1] = Array(repeating: Array(repeating: 0.0, count: 16), count: 10)


//Fill in matrix with random weights between 0 and 1/8
for x in 1...weights.count {
    for y in 1...weights[x-1].count {
        for z in 1...weights[x-1][y-1].count {
            weights[x-1][y-1][z-1] = Double.random0to1() / 8.0
        }
    }
}

//A matrix to hold the delta (error) values for each node
var errors = Array(repeating: Array(repeating: 0.0, count: 10), count: weights.count)
for i in 1...weights.count {
    errors[i-1] = Array(repeating: 0.0, count: weights[i-1].count + 1)
}



do {
    
    //Locate and load in the training file
    let location = Bundle.main.path(forResource: "training_data", ofType: "csv")
    let fileUrl = URL(fileURLWithPath: location!)
    let file = try String(contentsOf: fileUrl)
    let rows = file.components(separatedBy: .whitespacesAndNewlines).filter{!($0.isEmpty || $0 == "")}
    
    //Print the number of training examples
    let numExamples = rows.count
    let fivePercent = numExamples / 20
    let onePercent = numExamples / 100
    print(numExamples)
    
    var epoch = 0 
    var numCorrect = 0
    var numLoops = 0
    var sum_error = 0.0
    
    //Run the program until you are satisfied with the results
    //numExamples can be replaced with a specific percentage
    while numCorrect <= numExamples {
        
        //Reset the variables and print progress
        print("\n\n\(numCorrect)/\(numLoops)\n\n")
        print("Epoch: \(epoch)\nError:\(sum_error)\n\n")
        epoch = epoch + 1
        numCorrect = 0
        numLoops = 0
        sum_error = 0.0
        
        
        //Loop through all training examples once
        for row in rows {
            
            //Get an array of pixel values and confirm there are 784 pixels + an answer
            let fields = row.components(separatedBy: ",")
            if (fields.count == 785) {
                
                //Create an ImageVector containing answer and pixel values
                let vector = ImageVector(value: fields)
                let answer = vector.singleAnswer
                
                //Add another loop to track/print progress on current epoch
                numLoops = numLoops + 1
                if (numLoops % fivePercent == 0) {
                    print ("\(numLoops / onePercent)%")
                }
                
                //Initialize guess to an incorrect value
                var guess = -1
                
                /*
                *
                * Forward Propogation
                *
                */
                
                //Layers contains the values of all nodes
                var layers = [[Double]]()
                
                //layers[0] will now correspond to the inputs (pixel values)
                layers.append(vector.pixels)
                
                //Allows for a variable number of hidden layers
                for layer in 1...weights.count {
                    //Creates a new layer and then adds in a node using the weights and previous layers' values
                    layers.append([Double]())
                    for nodes in 1...weights[layer-1].count {
                        let answer = zip(weights[layer-1][nodes-1], layers[layer-1]).map(*).reduce(0,+)
                        layers[layer].append(NNUtility.sigmoid(z: answer))
                    }
                    
                    //Add in bias if not the output layer
                    if (layer != weights.count) {
                        layers[layer].append(1.0)
                    }

                }
                
                //After forward propogation check if guess was correct
                guess = NNUtility.getAnswer(outputs: layers[2])
                if (guess == answer!) {
                    numCorrect = numCorrect + 1
                }
                
                /*
                 *
                 * Back Propogation
                 *
                 */
                
                //Calculate errors of output layer
                for i in 1...layers[layers.count - 1].count {
                    let error = layers[layers.count-1][i-1] - vector.answer[i-1]
                    errors[weights.count - 1][i-1] = error
                    sum_error = sum_error + error * error
                }

                //Calculate error of remaining layers using weights and previous delta/errors
                for layer in weights.count - 1...1 {
                    let transposedWeights = NNUtility.transpose(input: weights[layer])
                    for node in 1...errors[layer-1].count {
                        let derivative = layers[layer][node-1] * (1.0-layers[layer][node-1])
                        
                        errors[layer-1][node-1] = zip(transposedWeights[node-1], errors[layer]).map(*).reduce(0,+) * derivative
                        // print(errors[layer-1][node-1])
                    }
                }
                
                //Calculate change and create new weights
                for layer in 1...weights.count {
                    for destinationNode in 1...weights[layer-1].count {
                        for sourceNode in 1...weights[layer-1][destinationNode-1].count {
                            let weight = weights[layer-1][destinationNode-1][sourceNode-1]
                            weights[layer-1][destinationNode-1][sourceNode-1] = weight - learningRate * errors[layer-1][destinationNode-1] * layers[layer-1][sourceNode-1]
                        }
                    }
                }
                
                
            }
        }
        
        //Update the learning rate to refine every epoch
        learningRate = learningRate * 0.9
        //Save progress so if program is halted, progress is saved
        NNUtility.saveWeights(weights: weights)
    }
} catch {
    print(error)
}


