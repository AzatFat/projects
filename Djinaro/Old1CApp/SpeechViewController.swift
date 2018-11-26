//
//  SpeechViewController.swift
//  Djinaro
//
//  Created by Azat on 08.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit
import Speech

class SpeechViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ru-RU"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecognizing = false
    var searchString = ""
    var foundSearch = 0
    var witchSpeech = ""
    
    @IBOutlet var speechToTextOutlet: UIButton!
    @IBOutlet var SpeecToText: UILabel!
    @IBAction func StartStopSpeechRecognition(_ sender: UIButton) {

        if isRecognizing == false {
            audioEngine.inputNode.removeTap(onBus: 0)
            self.recordAndRecognizeSpeech()
            speechToTextOutlet.setTitle("Поиск", for: UIControl.State.normal)
            isRecognizing = true
        } else {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            recognitionTask?.finish()
            isRecognizing = false
            speechToTextOutlet.setTitle("Запись", for: UIControl.State.normal)
            if let goodSearch = SpeecToText.text {
                searchString = goodSearch
            }
            witchSpeech = "goodSearch"
            if searchString != "" {
                //performSegue(withIdentifier: "speachSearch", sender: nil)
                performSegue(withIdentifier: "backToGoodsVC", sender: nil)
            }

        }
        
    }
    
    func applyRoundCorner (_ object: AnyObject) {
        object.layer.cornerRadius = object.frame.size.width / 2
        object.layer?.masksToBounds = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyRoundCorner(speechToTextOutlet)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        foundSearch = 0

    }
    
    
    func recordAndRecognizeSpeech() {
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
//        node.removeTap(onBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable {
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.SpeecToText.text = bestString
                print(bestString)
                //self.checkSearch(resultString: bestString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func checkSearch(resultString: String) {
        let separators = CharacterSet(charactersIn: " -,")
        let strArray = resultString.components(separatedBy: separators)
        var sizes = [String]()
        for i in strArray {
            switch i {
            case "37":
                sizes.append("37")
            case "38":
                sizes.append("38")
            case "39":
                sizes.append("39")
            case "40":
                sizes.append("40")
            case "41":
                sizes.append("41")
            case "42":
                sizes.append("42")
            case "43":
                sizes.append("43")
            case "44":
                sizes.append("44")
            case "45":
                sizes.append("46")
            case "36":
                sizes.append("36")
            case "размер":
                searchString = sizes.joined(separator: ",")
                speechToTextOutlet.setTitle("Запись", for: UIControl.State.normal)
                witchSpeech = "sizeSearch"
                SpeecToText.text = ""
                audioEngine.inputNode.removeTap(onBus: 0)
                audioEngine.stop()
                recognitionTask?.finish()
                isRecognizing = false
                if foundSearch == 0, searchString != "" {
                    performSegue(withIdentifier: "speachSearch", sender: nil)
                    foundSearch += 1
                }
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "speachSearch" {
            
            let controller = segue.destination as! itemsTableViewController
            if witchSpeech == "sizeSearch" {
                controller.spechSizeSearch(search: searchString)
            } else if witchSpeech == "goodSearch" {
                controller.spechGoodSearch(search: searchString)
            }
            controller.search.text = searchString
            speechToTextOutlet.setTitle("Запись", for: UIControl.State.normal)
            
        }
        
        if segue.identifier == "backToGoodsVC" {
            let controller = segue.destination as! GoodsTableViewController
            controller.searchGoods(search: searchString, sizes: "")
            controller.searchBar.text = searchString
            speechToTextOutlet.setTitle("Запись", for: UIControl.State.normal)
        }
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


