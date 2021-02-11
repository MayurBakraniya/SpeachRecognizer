//
//  ViewController.swift
//  callDemo
//
//  Created by MAC on 11/02/21.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var lb_speach: UILabel!
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var btnStart: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speachRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task = SFSpeechRecognitionTask()
    let recognizer = SFSpeechRecognizer()
    var isStart:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestPermission()
    }
    
    @IBAction func btn_Start_Stop(_ sender: UIButton) {
        isStart = !isStart
        
        if isStart{
            startSpeechRecognization()
            btnStart.setTitle("STOP", for: .normal)
        }else{
            cancelSpeechRecognizer()
            btnStart.setTitle("START", for: .normal)
        }
    }
    
    
    func requestPermission(){
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized{
                    print("Accepted")
                    self.btnStart.isEnabled = true
                }else if authState == .denied{
                    print("User denied permision")
                    self.btnStart.isEnabled = false
                }else if authState == .notDetermined{
                    print("User phone there are no phone recognizer")
                }else if authState == .restricted{
                    print("User has been restricated from the phone speech recognizer")
                }
            }
        }
    }
    
    func startSpeechRecognization(){
        let node = audioEngine.inputNode
        let recordingFormate = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormate) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        
        do{
            try audioEngine.start()
        }catch{
            print(error.localizedDescription)
        }
        
        guard let myRecognazation = SFSpeechRecognizer() else {
            print("Recognize not allow in your system")
            return
        }
        
        if myRecognazation.isAvailable{
            print("Recognization is now free")
        }
        
        recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            guard let response = result else {
                if error != nil{
                    print("error")
                }else{
                    print("Response are not getting")
                }
                return
            }
            
            let message = response.bestTranscription.formattedString
            print(message)
            self.lb_speach.text = message

            var lastString:String = ""
            
            for segment in response.bestTranscription.segments{
                let indexto = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                
                lastString = String(message[indexto...])
            }
            
            if lastString == "red"{
                self.viewColor.backgroundColor = .red
            }else if lastString.elementsEqual("green"){
                self.viewColor.backgroundColor = .systemGreen
            }else if lastString.elementsEqual("yellow"){
                self.viewColor.backgroundColor = .yellow
            }else if lastString.elementsEqual("black"){
                self.viewColor.backgroundColor = .black
            }else if lastString.elementsEqual("pink"){
                self.viewColor.backgroundColor = .systemPink
            }
            
        })
    }
    
    func cancelSpeechRecognizer(){
       // self.task.finish()
    //    task != nil
        
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    
    
}

