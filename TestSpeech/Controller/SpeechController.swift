//
//  SpeechController.swift
//  TestSpeech
//
//  Created by kita kensuke on 2020/07/13.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import Foundation
import UIKit
import Speech
import AVFoundation

@objc protocol SpeechControllerDelegate: class {
    //読み取り終了のキーワード
    func endWord() -> String
    //書き込まれるView
    @objc optional func getTextView() -> UITextView
}

class SpeechController {
    
    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine = AVAudioEngine()
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    weak var delegate: SpeechControllerDelegate?
    
    //読み取り終了
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
    
    //読み取り開始
    func startLiveTranscription(_ str: String ) throws {
        
        // もし前回の音声認識タスクが実行中ならキャンセル
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
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
                print("\(str):\(error)")
            } else {
                DispatchQueue.main.async {
                    let talkResult = result?.bestTranscription.formattedString
                    //文字起こし
                    guard let textView = self.delegate?.getTextView!() else {return}
                    textView.text = talkResult
                    guard let endWord = self.delegate?.endWord() else {return}
                    //読み取った文字の中に”完了”があったら終了
                    if talkResult?.contains(endWord) ?? false {
                        guard let talkResultBody = talkResult else {return}
                        //読み取った文字から”完了”を探してその前の文を取得
                        let talkIndex = talkResultBody.range(of: endWord)
                        let talkFlag = talkResultBody.distance(from: talkResultBody.startIndex, to: talkIndex!.lowerBound)
                        let talkValue = talkResultBody[talkResultBody.index(talkResultBody.startIndex, offsetBy: 0)..<talkResultBody.index(talkResultBody.startIndex, offsetBy: talkFlag)]
                        textView.text = String(talkValue)
                        self.stopLiveTranscription()
                        
                    }
                }
            }
        })
    }
    
}

