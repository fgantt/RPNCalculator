//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Floyd Gantt on 2/12/16.
//  Copyright © 2016 Edansys. All rights reserved.
//

import Foundation

class CalculatorBrain: CustomStringConvertible
{
    private enum Op: CustomStringConvertible
    {
        case Constant(String)
        case Variable(String)
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)

        var precedence: Int {
            switch self {
            case .BinaryOperation(_, let precedence, _):
                return precedence
            default:
                return Int.max
            }
        }
        
        var description: String {
            switch self {
            case .Constant(let symbol):
                return symbol
            case .Variable(let variable):
                return variable
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _, _):
                return symbol
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String : Op]()
    
    var constants = [String : Double]()
    
    init() {
        // inner function
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", 100, *))
        learnOp(Op.BinaryOperation("÷", 100) { $1 / $0 })
        learnOp(Op.BinaryOperation("+", 50, +))
        learnOp(Op.BinaryOperation("−", 50) { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("±", -))
        
        constants["π"] = M_PI
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Constant(let symbol):
                if let constantValue = constants[symbol] {
                    return (constantValue, remainingOps)
                }
                return (nil, remainingOps)
                
            case .Variable(let symbol):
                if let variableValue = variableValues[symbol] {
                    return (variableValue, remainingOps)
                }
                return (nil, remainingOps)
                
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        print(self)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(.Operand(operand))
        return evaluate()
    }
    
    var variableValues = [String : Double]()
    func pushOperand(symbol: String) -> Double? {
        opStack.append(.Variable(symbol))
        return evaluate()
    }
    
    func pushConstant(symbol: String) -> Double? {
        opStack.append(.Constant(symbol))  // verify constant exists?
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll()
        variableValues.removeAll()
    }
    
    private func stringify(ops: [Op], currentPrecedence: Int?) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Constant(let symbol):
                return (symbol, remainingOps)
                
            case .Variable(let symbol):
                return (symbol, remainingOps)
                
            case .Operand(let operand):
                return (String(format: "%g", operand), remainingOps)
                
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = stringify(remainingOps, currentPrecedence: nil)
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(let symbol, _, _):
                let op1Evaluation = stringify(remainingOps, currentPrecedence: op.precedence)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = stringify(op1Evaluation.remainingOps, currentPrecedence: op.precedence)
                    if let operand2 = op2Evaluation.result {
                        let wrapInParenthesis = currentPrecedence != nil && currentPrecedence! > op.precedence
                        let expression = "\(operand2) \(symbol) \(operand1)"
                        return (wrapInParenthesis ? "(\(expression))" : "\(expression)", op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    var description: String {
        var expressionResults = [String]()
        var remainingOps = opStack
        while !remainingOps.isEmpty {
            let expressionResult = stringify(remainingOps, currentPrecedence: nil)
            remainingOps = expressionResult.remainingOps
            if expressionResult.result == nil {
                break
            }
            expressionResults.append(expressionResult.result!)
        }
        return expressionResults.reverse().joinWithSeparator(",")
    }
}