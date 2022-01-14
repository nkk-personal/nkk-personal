//
//  ViewController.swift
//  JSONReader
//
//  Created by Naveen Keerthy on 1/12/22.
//

import UIKit

class ViewController: UIViewController {
    
    let todoService = TodoService()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTodos()
    }

    func fetchTodos() -> Void {
        todoService.fetch { result in
            switch result {
            case .success(let data):
                print("Sucess: ", data)
            case .failure(let error):
                print("Failure: ", error)
            default:
                print("Nothing worked")
            }
        }
    }
}

