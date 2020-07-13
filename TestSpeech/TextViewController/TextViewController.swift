//
//  TextViewController.swift
//  TestSpeech
//
//  Created by kita kensuke on 2020/07/13.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit

class TextViewController: UIViewController, SpeechControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    let speechController = SpeechController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechController.delegate = self
    }
    
    //画面描画時に録音開始
    override func viewWillAppear(_ animated: Bool) {
        try! speechController.startLiveTranscription("text")
    }
    
    //画面遷移で録音終了
    override func viewWillDisappear(_ animated: Bool) {
        speechController.stopLiveTranscription()
    }
    
    func endWord() -> String {
        return "完了"
    }
    
    func getTextView() -> UITextView {
        return textView
    }
 
}

