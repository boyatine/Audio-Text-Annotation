//
//  EditViewController.swift
//  Midterm Q2
//
//  Created by Wonsug E on 4/12/19.
//  Copyright © 2019 Wonsug E. All rights reserved.
//

import UIKit
import AVFoundation

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var previousVC = TableViewController()
    var location = -1
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // create audio session
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.overrideOutputAudioPort(.speaker)
        try? session.setActive(true)
        
        //URL to save the audio
        
        if let basePath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let pathComponents = [basePath, "audio.m4a"]
            if let audioURL = NSURL.fileURL(withPathComponents: pathComponents) {
                self.audioURL = audioURL
                //Create some settings
                var settings :[String:Any] = [:]
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
                settings[AVSampleRateKey] = 44100.0
                settings[AVNumberOfChannelsKey] = 2
                //Create the audio recorder
                audioRecorder = try? AVAudioRecorder(url: audioURL, settings: settings)
                audioRecorder?.prepareToRecord()
            }
        }
        
        let loadedImage = UIImage(data: previousVC.items[location].image!)
        imageView.image = loadedImage
        
        if let sound = previousVC.items[location].audioData {
            audioPlayer = try? AVAudioPlayer(data: sound)
        }
        
        textField.text = previousVC.items[location].name
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        if let audioRecorder = self.audioRecorder {
            if audioRecorder.isRecording {
                audioRecorder.stop()
                recordButton.setTitle("Record", for: .normal)
                playButton.isEnabled = true
                saveButton.isEnabled = true
                textField.isEnabled = true
            }
            else {
                audioRecorder.record()
                recordButton.setTitle("Stop", for: .normal)
                playButton.isEnabled = false;
                saveButton.isEnabled = false
                textField.isEnabled = false
            }
        }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        if let audioURL = self.audioURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.play()
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func organizeTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let item = previousVC.items[location]
            context.delete(item)
            try? context.save()
            
            let newItem = Item(entity: Item.entity(), insertInto: context )
            
            if let image = imageView.image {
                if let imageData = image.pngData() {
                    newItem.image = imageData
                }
            }
            
            if let audioURL = self.audioURL {
                newItem.audioData = try? Data(contentsOf: audioURL)
                try? context.save()
                navigationController?.popViewController(animated: true)
            }
            
            newItem.name = textField.text
            
            try? context.save()
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let choosenImage =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = choosenImage
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
