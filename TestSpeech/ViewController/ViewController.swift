//
//  ViewController.swift
//  TestSpeech
//
//  Created by kita kensuke on 2020/07/13.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {
    
    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine = AVAudioEngine()
    }
    
    //画面描画時に録音開始
    override func viewWillAppear(_ animated: Bool) {
        try! startLiveTranscription()
    }

    //画面遷移で録音終了
    override func viewWillDisappear(_ animated: Bool) {
        stopLiveTranscription()
    }
    
    
    func stopLiveTranscription() {
        //オーディオセッションをplaysessionに戻す
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)
        } catch{
            print("audio session error")
        }
        
        recognitionTask?.cancel()
        recognitionTask?.finish()
        recognitionTask = nil
        recognitionReq?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    func startLiveTranscription() throws {
        
        // もし前回の音声認識タスクが実行中ならキャンセル
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        //textView.text = ""
        
        // 音声認識リクエストの作成
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else {return}
        recognitionReq.shouldReportPartialResults = true
        
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // マイク入力の設定
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, time) in
            recognitionReq.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: recognitionReq, resultHandler: { (result, error) in
            if let error = error {
                print("view:\(error)")
            } else {
                DispatchQueue.main.async {
                    let talkResult = result?.bestTranscription.formattedString
                    //入力された音声を判定
                    if talkResult?.contains("テキスト") ?? false {
                        //text入力画面に移動
                        let vc = self.tabBarController?.viewControllers?[1];
                        self.tabBarController?.selectedViewController = vc
                    } else if talkResult?.contains("日付") ?? false {
                        //日付入力画面に移動
                        let vc = self.tabBarController?.viewControllers?[2];
                        self.tabBarController?.selectedViewController = vc
                    } else {
                        self.showActionAlert()
                    }
                    
                }
            }
        })
    }
    
    func showActionAlert() {
        let actionSheet = UIAlertController(title: "もう一度", message: "選択肢はタイトル、日付", preferredStyle: UIAlertController.Style.alert)
        
        let action1 = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            self.stopLiveTranscription()
            try! self.startLiveTranscription()
        })
        
        actionSheet.addAction(action1)
        //実際にAlertを表示する
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //textボタン
    @IBAction func tapTextButton(_ sender: Any) {
        //text入力画面に移動
        let vc = tabBarController?.viewControllers?[1];
        tabBarController?.selectedViewController = vc
    }
    
    //dateボタン
    @IBAction func tapDateButton(_ sender: Any) {
        //date入力画面に移動
        let vc = tabBarController?.viewControllers?[2];
        tabBarController?.selectedViewController = vc
    }
}

