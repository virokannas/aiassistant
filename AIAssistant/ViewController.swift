//
//  ViewController.swift
//  AIAssistant
//
//  Created by Simo Virokannas on 5/9/21.
//

import UIKit
import OpenAI


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Proven way to do variable-height cells: need to know the height. Sorry.
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let msg = self.messages[indexPath.row]
        let direction = msg.me ? "outgoing" : "incoming"
        let cell = self.table.dequeueReusableCell(withReuseIdentifier: "\(direction)BubbleCell", for: indexPath)
        if let cell = cell as? BubbleCell {
            cell.chatMessage = msg
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        let w = self.table.frame.width
        let msg = self.messages[indexPath.row]
        return CGSize(width: w, height: heightForLabel(text: msg.text, font: font, width: w - 170) + 32)
    }
    
    @IBOutlet var segmentController: UISegmentedControl!
    @IBOutlet var table: UICollectionView!
    @IBOutlet var entry: UITextField!
    @IBOutlet var actorA: UITextField!
    @IBOutlet var actorB: UITextField!
    @IBOutlet var setting: UITextField!
    @IBOutlet var raw: UISwitch!
    
    let ai_key : String = "YOUR_API_KEY_GOES_HERE"
    var actor1 : String = "Me"
    var actor2 : String = "AI"
    var backdrop : String = "AI is an intelligent assistant. It tries to answer to me truthfully."
    var client : OpenAI.Client? = nil
    var backbuffer : [String] = []
    var messages : [AIMessage] = []
    var firstMessage : Bool = true
    var orig_size : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.client = OpenAI.Client(apiKey: self.ai_key)
        
        self.table.register(BubbleCell.self, forCellWithReuseIdentifier: "incomingBubbleCell")
        self.table.register(BubbleCell.self, forCellWithReuseIdentifier: "outgoingBubbleCell")
        self.table.dataSource = self
        self.table.delegate = self
        
        self.entry.inputAccessoryView = UIView()
        self.actorA.inputAccessoryView = UIView()
        self.actorB.inputAccessoryView = UIView()
        self.setting.inputAccessoryView = UIView()

        self.actorA.text = UserDefaults.standard.string(forKey: "actors/A") ?? ""
        self.actorB.text = UserDefaults.standard.string(forKey: "actors/B") ?? ""
        self.setting.text = UserDefaults.standard.string(forKey: "setting") ?? ""
        self.segmentController.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "engine/selected")
        self.raw.isOn = UserDefaults.standard.bool(forKey: "raw")

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.reset()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if orig_size == 0.0 {
                orig_size = self.view.frame.size.height
            }
            self.view.frame.size.height = orig_size - keyboardSize.height
        }
        self.table.layoutIfNeeded()
        self.delayedScrollToBottom()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.size.height = orig_size
        self.table.layoutIfNeeded()
        self.delayedScrollToBottom()
    }
    
    func delayedScrollToBottom() {
        Timer.scheduledTimer(withTimeInterval: TimeInterval(0.2), repeats: false) { _ in
            self.table.scrollToBottom(animated: true)
        }
    }

    func longestResponse(_ choices: [OpenAI.Completion.Choice]?) -> String {
        // We'll want the longest combination of words that still ends with a . ! or ?
        if let choices = choices {
            var longest = ""
            for choice in choices {
                var text = choice.text
                if self.raw.isOn {
                    return text
                }
                var lastsep = 0
                for sep in [".", "!", "?"] {
                    if let idx = text.lastIndex(of: sep.first!) {
                        if idx.utf16Offset(in: text) > lastsep {
                            lastsep = idx.utf16Offset(in: text)
                        }
                    }
                }
                if lastsep > 0 {
                    text = String(text[...String.Index(utf16Offset: lastsep, in: text)])
                }
                if text.count > longest.count {
                    longest = text
                }
            }
            if longest != "" {
                return longest.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                return choices.first?.text ?? "(no response)"
            }
        }
        return "(no response)"
    }
    
    func compileFullText(withPrompt: Bool = false) -> String {
        if raw.isOn {
            return self.backbuffer.joined()
        }
        var full_text = ""
        var story = self.setting.text ?? ""
        if story == "" {
            story = self.backdrop
        }
        if withPrompt {
            full_text.append(story + "\n\n")
            let start_idx = max(self.backbuffer.count - 32, 0)
            let the_buffer = self.backbuffer[start_idx...]
            full_text.append(the_buffer.joined(separator: "\n"))
            full_text.append("\n\(self.actor2):")
        }
        return full_text
    }
    
    func listAllStops() -> [String]? {
        if self.raw.isOn {
            return nil
        }
        return [
            "\n",
            self.actor1 + ":",
            self.actor2 + ":"
        ]
    }
    
    func addMessage(_ msg : AIMessage) {
        self.messages.append(msg)
        self.table.reloadData()
        Timer.scheduledTimer(withTimeInterval: TimeInterval(0.3), repeats: false) { _ in
            self.table.scrollToBottom(animated: true)
        }
    }

    @IBAction func send() {
        UserDefaults.standard.setValue(self.segmentController.selectedSegmentIndex, forKey: "engine/selected")
        UserDefaults.standard.setValue(self.actorA.text ?? "", forKey: "actors/A")
        UserDefaults.standard.setValue(self.actorB.text ?? "", forKey: "actors/B")
        UserDefaults.standard.setValue(self.setting.text ?? "", forKey: "setting")
        UserDefaults.standard.setValue(self.raw.isOn, forKey: "raw")
        let engines : [OpenAI.Engine.ID] = [.davinci, .curie, .babbage, .ada]
        let engine = engines[self.segmentController.selectedSegmentIndex]
        if let client = self.client {
            if let text = self.entry.text {
                self.actor1 = self.actorA.text ?? self.actor1
                self.actor2 = self.actorB.text ?? self.actor2
                if self.actor1 == "" {
                    self.actor1 = "Me"
                }
                if self.actor2 == "" {
                    self.actor2 = "AI"
                }
                self.entry.text = ""
                if self.raw.isOn {
                    self.backbuffer.append("\(text)")
                } else {
                    self.backbuffer.append("\(self.actor1): \(text)")
                }
                self.addMessage(AIMessage(text, me: true))
                Timer.scheduledTimer(withTimeInterval: TimeInterval(0.3+Float.random(in: 0 ..< 1.0)), repeats: false) { _ in
                    self.addMessage(AIMessage("...", me:false))
                    let prompt = self.compileFullText(withPrompt: true)
                    NSLog("\(prompt)")
                    client.completions(engine: engine, prompt: prompt, numberOfTokens: ...32, numberOfCompletions: 1, stop: self.listAllStops()) { result in
                        guard case .success(let completions) = result else { return }
                        let response = self.longestResponse(completions.first?.choices)
                        if self.raw.isOn {
                            self.backbuffer.append(response)
                        } else {
                            self.backbuffer.append("\(self.actor2): \(response)")
                        }
                        DispatchQueue.main.async {
                            _ = self.messages.popLast()
                            self.addMessage(AIMessage(response, me: false))
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func tapGesture() {
        self.view.endEditing(true)
    }
    
    @IBAction func reset() {
        self.messages = []
        // Cheap trick to get to the bottom of the screen
        for _ in 0 ..< 8 {
            self.addMessage(AIMessage(" ", me: true, true))
        }
        self.backbuffer = []
    }
    

}

