//
//  DetailViewController.swift
//  TestSpeech
//
//  Created by kita kensuke on 2020/07/13.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    var detailtext: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = detailtext
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
