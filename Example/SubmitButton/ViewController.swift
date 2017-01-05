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
        firstButton.delegate = self
        firstButton.loadingType = .timeLimited
        secondButton.delegate = self
        secondButton.loadingType = .timeLimited
        thirdButton.delegate = self
        thirdButton.loadingType = .continuous
        fourthButton.delegate = self
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

extension ViewController: SubmitButtonDelegate {
    func didFinishedTask(sender: SubmitButton) {
        if sender == firstButton {
            sender.completeAnimation(status: .success)
        } else if sender == secondButton {
            sender.completeAnimation(status: .failed)
        }
    }
}
