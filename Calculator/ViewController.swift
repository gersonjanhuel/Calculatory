//
//  ViewController.swift
//  Calculator
//
//  Created by Gerson Janhuel on 10/16/16.
//  Copyright © 2016 Gerson Janhuel. All rights reserved.
//

/*
 Batasan :
 1. layar di atas 11 digit jadi exponent 
 2. tombol AC belum bisa handle history 
 
*/

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var btnOp4: UIButton!
    @IBOutlet weak var btnOp3: UIButton!
    @IBOutlet weak var btnOp2: UIButton!
    @IBOutlet weak var btnOp1: UIButton!
    @IBOutlet weak var btnAC: UIButton!
    
    var isScreenFull:Bool = false
    var isEqualBtnPressed: Bool = false
    
    typealias opFunc = (Double, Double) -> Double
    let ops: [String: opFunc] = [ "+" : add, "-" : sub, "*" : mul, "/" : div ]
    let ops_symbol: [String] = ["+" ,"-", "*", "/"]
    
    var tempResult: Double = 0
    var tempResultDisplay = ""
    
    var numStack: [Double] = [] // tampung bilangan
    var opStack: [String] = [] // tampung operator
    
    var numberIsActive = true
    var operatorIsActive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //tambah gesture listener untuk Label
        let swipeToRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipe(sender:)))
        swipeToRightGesture.direction = UISwipeGestureRecognizerDirection.right
        self.resultLabel.addGestureRecognizer(swipeToRightGesture)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func calculate(newOp: String) {
        if tempResultDisplay != "" && !numStack.isEmpty {
            let stackOp = opStack.last
            if !((stackOp == "+" || stackOp == "-") && (newOp == "*" || newOp == "/")) {
                let oper = ops[opStack.removeLast()]
                tempResult = oper!(numStack.removeLast(), tempResult)
                doEqual()
            }
        }
        opStack.append(newOp)
        numStack.append(tempResult)
        tempResultDisplay = ""
        showResult()
        isScreenFull = false
        
    }
    
    func doEqual() {
        isEqualBtnPressed = true
        if !numStack.isEmpty {
            let oper = ops[opStack.removeLast()]
            tempResult = oper!(numStack.removeLast(), tempResult)
            if !opStack.isEmpty {
                doEqual()
            }
        }
        showResult()
        tempResultDisplay = ""
        isScreenFull = false
        isEqualBtnPressed = false
        resetOpBtnFX()
    }
    
    func showResult() {
        var screenDisplay = ""
        
        //check apakah genap atau ada angka belakang koma
        let selisih:Double = tempResult - floor(tempResult)
        
        screenDisplay = formatDecimal(tempNumber: tempResult)
        
        if (selisih > 1e-11) {
            print("masuk bilangan berkoma")
            var temp_str = "\(tempResult)"
            
            //simpan dulu bilangan dibelakang koma
            let index_koma = temp_str.characters.index(of: ".")
            let belakang_koma = temp_str.substring(from: index_koma!)
           
            //bilangan di depan koma
            let index_koma_real = screenDisplay.characters.index(of: ".")
            let depan_comma = screenDisplay.substring(to: index_koma_real!)
            
            screenDisplay = depan_comma + belakang_koma
            
            /*if(temp_str.characters.count >= 9) {
                
                if(isEqualBtnPressed == true && depan_comma.characters.count >= 9) {
                    screenDisplay = formatDecimal(tempNumber: tempResult)
                }
            }*/
            
        } else {
            print("masuk bilangan bulat ")
        }
        
        var temp_str_genap = "\(Int(tempResult))"
        if(temp_str_genap.characters.count >= 9) {
            if(isEqualBtnPressed == true) {
                screenDisplay = formatExponent(tempResult)
            }
        }
        
        resultLabel.text = screenDisplay
    }
    
    func handleInput(str: String) {
        resetOpBtnFX()
        
        if str == "." {
            if (tempResultDisplay.characters.count == 0){
                tempResultDisplay = "0"
            }
            //tempResult = Double((tempResultDisplay as NSString).doubleValue)
            //showResult()
            let display_dot = resultLabel.text! + str
            resultLabel.text = display_dot
            tempResultDisplay += str
            
        } else {
            if str == "-" {
                if tempResultDisplay.hasPrefix(str) {
                    let current_index = tempResultDisplay.index(after: tempResultDisplay.startIndex)
                    tempResultDisplay = tempResultDisplay.substring(from: current_index)
                    
                    tempResult = Double((tempResultDisplay as NSString).doubleValue)
                    showResult()
                } else {
                    
                    tempResultDisplay = str + tempResultDisplay
                    
                    tempResult = Double((tempResultDisplay as NSString).doubleValue)
                    showResult()
                    
                    if (tempResult == 0){
                        tempResultDisplay = "0"
                        tempResultDisplay = str + tempResultDisplay
                        resultLabel.text = tempResultDisplay
                    }
                }
            } else if str == "0" {
                tempResultDisplay += str
                tempResult = Double((tempResultDisplay as NSString).doubleValue)
                
                if(isDotExist(stringToSearch: tempResultDisplay)) {
                    resultLabel.text = tempResultDisplay
                } else {
                    if (tempResult == 0)  {
                        tempResultDisplay = ""
                    }
                    showResult()
                }
                
            } else {
                tempResultDisplay += str
                print("tempResultDisplay "+tempResultDisplay)
                tempResult = Double((tempResultDisplay as NSString).doubleValue)
                
                showResult()
                print("tempResult \(tempResult)")
                
            }
        }
        
        if(tempResultDisplay.characters.count >= 9) {
            isScreenFull = true
        }
    }
    
    func formatDecimal(tempNumber:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        return numberFormatter.string(from: NSNumber(value: (tempNumber)))!
    }
    
    func formatExponent(_ val:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.scientific
        numberFormatter.positiveFormat = "0.#E0"
        numberFormatter.exponentSymbol = "e"
        if let stringFromNumber = numberFormatter.string(from: NSNumber(value: (val))) {
            return stringFromNumber  // "5e+2"
        }
        
        return "\(val)"
    }
    
    func isDotExist(stringToSearch: String) -> Bool {
        if (stringToSearch.range(of: ".") != nil) {
            return true
        }
        return false
    }
    
    func resetOpBtnFX() {
        btnOp1.layer.borderWidth = 0
        btnOp2.layer.borderWidth = 0
        btnOp3.layer.borderWidth = 0
        btnOp4.layer.borderWidth = 0
    }
    
    func respondToSwipe(sender:UISwipeGestureRecognizer) {
        //remove last character
        
        if(tempResultDisplay.characters.count > 0 ) {
            tempResultDisplay = tempResultDisplay.substring(to: tempResultDisplay.index(before: tempResultDisplay.endIndex))
            
            tempResult = Double((tempResultDisplay as NSString).doubleValue)
            showResult()
            
            if(tempResultDisplay.characters.count > 0 ) {
                let last_char:String = String(tempResultDisplay.characters.last!)
                print(last_char)
            
                tempResultDisplay = tempResultDisplay.substring(to: tempResultDisplay.index(before: tempResultDisplay.endIndex))
                handleInput(str: last_char)
            }
        }
    }
    
    @IBAction func numberBtnPressed(_ sender: AnyObject) {
        if(isScreenFull == false) {
            handleInput(str: "\(sender.tag!)")
            btnAC.setTitle("C", for: .normal)
            numberIsActive = true
        }
    }
    
    @IBAction func acBtnPressed(_ sender: AnyObject) {
        tempResultDisplay = ""
        isScreenFull = false
        tempResult = 0
        showResult()
        
        numStack.removeAll()
        opStack.removeAll()
        
        btnAC.setTitle("AC", for: .normal)
    }
    
    @IBAction func plusminusBtnPressed(_ sender: AnyObject) {
        if tempResultDisplay.isEmpty {
            tempResultDisplay = resultLabel.text!
        }
        handleInput(str: "-")
    }
    
    @IBAction func opratorBtnPressed(_ sender: AnyObject) {
        resetOpBtnFX()
        sender.layer.borderWidth = 1
        sender.layer.borderColor = UIColor.black.cgColor
        
        calculate(newOp: ops_symbol[sender.tag])
    }
    
    @IBAction func resultBtnPressed(_ sender: AnyObject) {
        doEqual()
    }
    
    @IBAction func dotBtnPressed(_ sender: AnyObject) {
        //check apakah sudah ada dot sebelumnyaa
        if isDotExist(stringToSearch: tempResultDisplay) == false {
            handleInput(str: ".")
            
        }
    }
    
}

// operator functions
func add(a: Double, b: Double) -> Double {
    let result = a + b
    return result
}
func sub(a: Double, b: Double) -> Double {
    let result = a - b
    return result
}
func mul(a: Double, b: Double) -> Double {
    let result = a * b
    print(result)
    
    return result
}
func div(a: Double, b: Double) -> Double {
    let result = a / b
    return result
}



