//
//  ViewController.swift
//  SubmitButton
//
//  Created by Jagajith M Kalarickal on 12/07/2016.
//  Copyright (c) 2016 Jagajith M Kalarickal. All rights reserved.
//

import UIKit
import SubmitButton

class ViewController: UIViewController, SubmitButtonDelegate{

    @IBOutlet var button1: SubmitButton!
    @IBOutlet var button2: SubmitButton!
    @IBOutlet var button3: SubmitButton!
    @IBOutlet var button4: SubmitButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        button1.delegate = self
        button1.loadingType = .timeLimited
        button2.delegate = self
        button2.loadingType = .timeLimited
        button3.delegate = self
        button3.loadingType = .continuous
        button4.delegate = self
        button4.loadingType = .continuous
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func button1OnClick(_ sender: SubmitButton) {
        
    }
    
    @IBAction func button2OnClick(_ sender: SubmitButton) {
        
    }
    
    @IBAction func button3OnClick(_ sender: SubmitButton) {
        if sender.isSelected {
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                sender.completeAnimation(status: .success)
            }
        }
    }
    
    @IBAction func button4OnClick(_ sender: SubmitButton) {
        if sender.isSelected {
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                sender.completeAnimation(status: .failed)
            }
        }
    }
    
    func didFinishedTask(sender: SubmitButton) {
        if sender == button1 {
            sender.completeAnimation(status: .success)
        }else if sender == button2{
            sender.completeAnimation(status: .failed)
        }
    }

}

