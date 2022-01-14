//
//  ViewController.swift
//  AllInOne
//
//  Created by Naveen Keerthy on 1/12/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        clousers()
    }
    
    func clousers() {
        let cloWithoutParams = {
            print("Without any parameters")
        }
        
        cloWithoutParams()
        
        
        let cloWithParams = { (v1: Int, v2: Int) in
            print(v1+v2)
        }
        
        cloWithParams(10,20)
        
        let cloWithParamsShortCut = {
//            return $0 * $1
        }
        
//        cloWithParamsShortCut(10,10)
        
        
        let cloWithNothing = { _ in }
        
        cloWithNothing()
    }


}

