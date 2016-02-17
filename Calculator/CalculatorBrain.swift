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
    enum Result: CustomStringConvertible
    {
        case Success(Double)
        
        // General error with message
        case Error(String)
        
        // Specific errors
        case DivideByZero
        case ConstantMissing(String)
        case OperandMissing
        case SquareRootOfNegativeNumber
        case VariableMissing(String)
        
        var description: String {
            switch self {
            case .Success(let result):
                return String(format: "%g", result)
            case .Error(let message):
                return message
            case .DivideByZero:
                return "Divide by zero"
            case .ConstantMissing(let symbol):
                return "Constant \(symbol) not defined"
            case .OperandMissing:
                return "Not enough operands"
            case SquareRootOfNegativeNumber:
                return "Square root of a negative number"
            case .VariableMissing(let symbol):
                return "Variable \(symbol) not defined"
            }
        }
    }
    
    private enum Op: CustomStringConvertible
    {
        case Constant(String)
        case Variable(String)
        case Operand(Double)
        case UnaryOperation(String, Double -> Double,
            (Double -> Result?)?)
        case BinaryOperation(String, Int, (Double, Double) -> Double,
            ((Double, Double) -> Result?)?)

        var precedence: Int {
            switch self {
            case .BinaryOperation(_, let precedence, _, _):
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
            case .UnaryOperation(let symbol, _, _):
                return symbol
            case .BinaryOperation(let symbol, _, _, _):
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
        
        learnOp(Op.BinaryOperation("×", 100, *, nil))
        learnOp(Op.BinaryOperation("÷", 100, { $1 / $0 },
            { divisor, _ in return divisor == 0.0 ? .DivideByZero : nil }))
        
        learnOp(Op.BinaryOperation("+", 50, +, nil))
        learnOp(Op.BinaryOperation("−", 50, { $1 - $0 }, nil))
        learnOp(Op.UnaryOperation("√", sqrt,
            { $0 < 0 ? .SquareRootOfNegativeNumber : nil }))
        
        learnOp(Op.UnaryOperation("cos", cos, nil))
        learnOp(Op.UnaryOperation("sin", sin, nil))
        learnOp(Op.UnaryOperation("±", -, nil))
        
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
                
            case .Variable(let symbol):
                if let variableValue = variableValues[symbol] {
                    return (variableValue, remainingOps)
                }
                
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation, _):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, _, let operation, _):
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
        print(evaluateAndReportErrors())
        return result
    }
    
    private func evaluateAndReportErrors(ops: [Op]) -> (result: Result, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Constant(let symbol):
                if let constantValue = constants[symbol] {
                    return (.Success(constantValue), remainingOps)
                }
                return (.ConstantMissing(symbol), remainingOps)
                
            case .Variable(let symbol):
                if let variableValue = variableValues[symbol] {
                    return (.Success(variableValue), remainingOps)
                }
                return (.VariableMissing(symbol), remainingOps)
                
            case .Operand(let operand):
                return (.Success(operand), remainingOps)
                
            case .UnaryOperation(_, let operation, let verifier):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    if let failureResult = verifier?(operand) {
                        return (failureResult, operandEvaluation.remainingOps)
                    }
                    return (.Success(operation(operand)), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, _, let operation, let verifier):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        if let failureResult = verifier?(operand1, operand2) {
                            return (failureResult, op2Evaluation.remainingOps)
                        }
                        return (.Success(operation(operand1, operand2)), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (.OperandMissing, ops)
    }
    
    func evaluateAndReportErrors() -> Result {
        guard !opStack.isEmpty else { return .Success(0) }
        return evaluateAndReportErrors(opStack).result
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
    
    func undo() -> Double? {
        opStack.removeLast()
        return evaluate()
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
                
            case .UnaryOperation(let symbol, _, _):
                let operandEvaluation = stringify(remainingOps, currentPrecedence: nil)
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(let symbol, _, _, _):
                let wrapInParenthesis = currentPrecedence != nil && currentPrecedence! > op.precedence
                let op1Evaluation = stringify(remainingOps, currentPrecedence: op.precedence)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = stringify(op1Evaluation.remainingOps, currentPrecedence: op.precedence)
                    if let operand2 = op2Evaluation.result {
                        let expression = "\(operand2) \(symbol) \(operand1)"
                        return (wrapInParenthesis ? "(\(expression))" : "\(expression)", op2Evaluation.remainingOps)
                    } else {
                        let expression = "? \(symbol) \(operand1)"
                        return (wrapInParenthesis ? "(\(expression))" : "\(expression)", op1Evaluation.remainingOps)
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
            if let result = expressionResult.result {
                expressionResults.append(result)
            } else {
                expressionResults.append("?")
                break
            }
        }
        return expressionResults.reverse().joinWithSeparator(",")
    }
}