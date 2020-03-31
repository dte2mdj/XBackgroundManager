//
//  ViewController.swift
//  XBackgroundManager
//
//  Created by dte2mdj on 03/31/2020.
//  Copyright (c) 2020 dte2mdj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    let timer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var time = 0
        
        timer.schedule(deadline: .now(), repeating: .milliseconds(1000))
        timer.setEventHandler { [weak self] in
            time += 1
            
            DispatchQueue.main.async { self?.updateTime(t: time) }
        }
        
        if #available(iOS 10.0, *) {
            timer.activate()
        } else {
            // Fallback on earlier versions
            
        }
    }

    func updateTime(t: Int) {
        print(t)
        timeLabel.text = "\(t)"
    }
}

