//
//  ViewController.swift
//  Calculator
//
//  Created by Floyd Gantt on 1/26/16.
//  Copyright © 2016 Edansys. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()  // Model
    
    var displayResult: CalculatorBrain.Result = .Success(0.0) {
        didSet {
            displayLabel.text = displayResult.description
            let description = brain.description
            if !description.isEmpty {
                historyLabel.text = description + " ="
            }
        }
    }
    
    var displayValue: Double? {
        get {
            return Double(displayLabel.text!)
        }
        set {
            displayLabel.text! = newValue != nil ? String(format: "%g", newValue!) : " "
            let description = brain.description
            if !description.isEmpty {
                historyLabel.text = description + " ="
            }
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        brain.clear()
        displayLabel.text = "0"
        historyLabel.text = ""
    }
    
    @IBAction func setMemory(sender: UIButton) {
        if let value = displayValue {
            userIsInTheMiddleOfTypingANumber = false
            brain.variableValues["M"] = value
            displayResult = brain.evaluateAndReportErrors()
//            if let result = brain.evaluate() {
//                displayValue = result
//            }
        }
    }
    
    @IBAction func pushMemory(sender: UIButton) {
        enter()
        brain.pushOperand("M")
        displayResult = brain.evaluateAndReportErrors()
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if digit == "." && userIsInTheMiddleOfTypingANumber && displayLabel.text!.containsString(".") { return }
        
        if userIsInTheMiddleOfTypingANumber {
            displayLabel.text = displayLabel.text! + digit
        } else {
            displayLabel.text = digit == "." ? "0\(digit)" : "\(digit)"
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func backspace(sender: UIButton) {
        if (userIsInTheMiddleOfTypingANumber) {
            displayLabel.text! = String(displayLabel.text!.characters.dropLast(1))
            if displayLabel.text!.characters.count == 0 || displayLabel.text! == "-" {
                displayLabel.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        } else {
            //displayValue = 
            brain.undo()
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    @IBAction func enter(sender: UIButton) {
        enter()
    }
    
    private func enter() {
        guard displayValue != nil else { return }
        userIsInTheMiddleOfTypingANumber = false
        //displayValue = 
        brain.pushOperand(displayValue!)
        displayResult = brain.evaluateAndReportErrors()
    }
    
    @IBAction func changeSign(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            if let currentValue = displayLabel.text {
                if currentValue.hasPrefix("-") {
                    displayLabel.text! = String(currentValue.characters.dropFirst(1))
                } else {
                    displayLabel.text! = "-\(currentValue)"
                }
            }
        } else {
            //displayValue = 
            brain.performOperation(operation)
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    @IBAction func pi(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        displayValue = brain.constants["π"]
        brain.pushConstant(sender.currentTitle!)
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            //displayValue = 
            brain.performOperation(operation)
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

