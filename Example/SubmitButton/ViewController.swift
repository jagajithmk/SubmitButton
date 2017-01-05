//
//  ViewController.swift
//  SubmitButton
//
//  Created by Jagajith M Kalarickal on 12/07/2016.
//  Copyright (c) 2016 Jagajith M Kalarickal. All rights reserved.
//

import UIKit
import SubmitButton

class ViewController: UIViewController {

    @IBOutlet var firstButton: SubmitButton!
    @IBOutlet var secondButton: SubmitButton!
    @IBOutlet var thirdButton: SubmitButton!
    @IBOutlet var fourthButton: SubmitButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        firstButton.loadingType = .timeLimited
        firstButton.taskCompletion = {_ in
            self.firstButton.completeAnimation(status: .success)
        }
        secondButton.loadingType = .timeLimited
        secondButton.taskCompletion = {_ in
            self.secondButton.completeAnimation(status: .failed)
        }
        thirdButton.loadingType = .continuous
        fourthButton.loadingType = .continuous
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func firstButtonOnClick(_ sender: SubmitButton) {
    }
    @IBAction func secondButtonOnClick(_ sender: SubmitButton) {
    }
    @IBAction func thirdButtonOnClick(_ sender: SubmitButton) {
        if sender.isSelected {
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when) {
                sender.completeAnimation(status: .success)
            }
        }
    }
    @IBAction func fourthButtonOnClick(_ sender: SubmitButton) {
        if sender.isSelected {
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when) {
                sender.completeAnimation(status: .failed)
            }
        }
    }
}
