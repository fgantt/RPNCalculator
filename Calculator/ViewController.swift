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
    var operandStack = Array<Double>()
    
    
    var displayValue: Double? {
        get {
            return Double(displayLabel.text!)
        }
        set {
            displayLabel.text! = newValue != nil ? "\(newValue!)" : "0"
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.removeAll()
        displayLabel.text = "0"
        historyLabel.text = ""
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if digit == "." && userIsInTheMiddleOfTypingANumber && displayLabel.text!.containsString(".") { return }
        
        if userIsInTheMiddleOfTypingANumber {
            displayLabel.text = displayLabel.text! + digit
        } else {
            if digit == "." {
                displayLabel.text = "0\(digit)"
            } else {
                displayLabel.text = "\(digit)"
            }
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func backspace(sender: UIButton) {
        guard userIsInTheMiddleOfTypingANumber else { return }
        displayLabel.text! = String(displayLabel.text!.characters.dropLast(1))
        if displayLabel.text!.characters.count == 0 || displayLabel.text! == "-" {
            displayLabel.text = "0"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func enter(sender: UIButton) {
        appendHistory(displayLabel.text!)
        appendHistory("↩︎")
        enter()
    }
    
    private func enter() {
        guard displayValue != nil else { return }
        operandStack.append(displayValue!)
        userIsInTheMiddleOfTypingANumber = false
        print("operandStack = \(operandStack)")
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
                appendHistory(operation)
            }
        } else {
            let operationSuccess = performOperation { -$0 }
            if operationSuccess {
                appendHistory(operation)
                appendHistory("=")
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        var operationSuccess = false
        
        if userIsInTheMiddleOfTypingANumber {
            appendHistory(displayLabel.text!)
            enter()
        }
        
        switch (operation) {
        case "±": operationSuccess = performOperation { -$0 }
        case "×": operationSuccess = performOperation { $0 * $1 }
        case "÷": operationSuccess = performOperation { $1 / $0 }
        case "+": operationSuccess = performOperation { $0 + $1 }
        case "−": operationSuccess = performOperation { $1 - $0 }
        case "√": operationSuccess = performOperation { sqrt($0) }
        case "cos": operationSuccess = performOperation { cos($0) }
        case "sin": operationSuccess = performOperation { sin($0) }
        case "π":
            displayValue = M_PI
            appendHistory("π")
            enter()
        default: break;
        }
        
        if (operationSuccess) {
            appendHistory("\(operation)")
        
            if operation != "π" {
                appendHistory("=")
            }
        }
        
    }
    
    func performOperation(operation: (Double, Double) -> Double) -> Bool {
        guard operandStack.count >= 2 else { return false }
        displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
        enter()
        return true
    }
    
    // @nonobjc allows Swift overloading in Obj-C interoperable class (inherits from UIViewController).
    @nonobjc
    func performOperation(operation: Double -> Double) -> Bool {
        guard operandStack.count >= 1 else { return false }
        displayValue = operation(operandStack.removeLast())
        enter()
        return true
    }
    
    private func appendHistory(value: String) {
        if value != "=" && historyLabel.text!.hasSuffix(" =") {
            let toIndex = historyLabel.text!.endIndex.advancedBy(-2)
            historyLabel.text! = historyLabel.text!.substringToIndex(toIndex)
        }
        historyLabel.text! += historyLabel.text!.characters.count > 0 ? " " : ""
        historyLabel.text! += value
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

