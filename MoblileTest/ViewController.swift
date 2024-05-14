//
//  ViewController.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 14/5/24.
//

import UIKit
import Reusable

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleDrawButton(_ sender: UIButton) {
        let viewController = DrawingViewController.instantiate()
        viewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(viewController, animated: true)
    }
    
    @IBAction func handleAnimationButton(_ sender: UIButton) {
    }

}

