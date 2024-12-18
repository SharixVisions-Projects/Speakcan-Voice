//
//  VoiceToTextViewController.swift
//  Linguamaster
//
//  Created by Developer UCF on 31/07/2024.
//

import UIKit
import Speech
import AVKit
import Lottie

class VoiceToTextViewController: UIViewController,UITextViewDelegate, UITextFieldDelegate ,UIGestureRecognizerDelegate ,AVSpeechSynthesizerDelegate{
    
    @IBOutlet weak var Micbtn: UIButton!
        @IBOutlet weak var Titlelbl: UILabel!
        @IBOutlet weak var TranslateTolbl: UILabel!
        @IBOutlet weak var Tolbl: UILabel!
        @IBOutlet weak var FromTV: UITextView!
        @IBOutlet weak var FromCountryTF: DropDown!
        @IBOutlet weak var ToTV: UITextView!
        @IBOutlet weak var ToCountryTF: DropDown!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
        
    @IBOutlet weak var mediumAI: UIActivityIndicatorView!
    var ToCountryCode = String()
        let placeholderText = "Record text to translate..."
        var speechRecognizer: SFSpeechRecognizer? // Modified: Initialize without a locale for auto-detection
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let audioEngine = AVAudioEngine()
        var speechSynthesizer = AVSpeechSynthesizer()
        
        // Countries array remains the same...
    private var animationView: LottieAnimationView!
    private var isAnimationPlaying = false
    
    let countries: [Country] = [
        Country(name: "United States", flag: "🇺🇸", code: "en"),
        Country(name: "Spain", flag: "🇪🇸", code: "es"),
        Country(name: "France", flag: "🇫🇷", code: "fr"),
        Country(name: "Germany", flag: "🇩🇪", code: "de"),
        Country(name: "Italy", flag: "🇮🇹", code: "it"),
        Country(name: "Japan", flag: "🇯🇵", code: "ja"),
        Country(name: "China", flag: "🇨🇳", code: "zh"),
        Country(name: "Russia", flag: "🇷🇺", code: "ru"),
        Country(name: "India", flag: "🇮🇳", code: "hi"),
        Country(name: "Brazil", flag: "🇧🇷", code: "pt"),
        Country(name: "Canada", flag: "🇨🇦", code: "en"),
        Country(name: "Mexico", flag: "🇲🇽", code: "es"),
        Country(name: "South Korea", flag: "🇰🇷", code: "ko"),
        Country(name: "Turkey", flag: "🇹🇷", code: "tr"),
        Country(name: "Saudi Arabia", flag: "🇸🇦", code: "ar"),
        Country(name: "Sweden", flag: "🇸🇪", code: "sv"),
        Country(name: "Norway", flag: "🇳🇴", code: "no"),
        Country(name: "Denmark", flag: "🇩🇰", code: "da"),
        Country(name: "Finland", flag: "🇫🇮", code: "fi"),
        Country(name: "Netherlands", flag: "🇳🇱", code: "nl"),
        Country(name: "Switzerland", flag: "🇨🇭", code: "de"),
        Country(name: "Australia", flag: "🇦🇺", code: "en"),
        Country(name: "New Zealand", flag: "🇳🇿", code: "en"),
        Country(name: "South Africa", flag: "🇿🇦", code: "af"),
        Country(name: "Argentina", flag: "🇦🇷", code: "es")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLottieAnimation()
        setupSpeech()
        activityIndicator.isHidden = true
        ToCountryTF.isSearchEnable = false
        FromCountryTF.isSearchEnable = false
        speechSynthesizer.delegate = self
        
        let countryNamesAndFlags = countries.map { "\($0.flag) \($0.name)" }

        FromCountryTF.optionArray = countryNamesAndFlags
        FromCountryTF.didSelect { [weak self] (selectedText, index, id) in
            guard let self = self else { return }
            let selectedCountryCode = self.countries[index].code
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: selectedCountryCode)) // Optional: set to specific locale
            let name = self.countries[index].name
            self.FromCountryTF.text = "(\(name))"
            print("Selected from Country Code: \(selectedCountryCode)")
        }
        ToCountryTF.optionArray = countryNamesAndFlags
        ToCountryTF.didSelect { [weak self] (selectedText, index, id) in
            guard let self = self else { return }
            let selectedCountryCode = self.countries[index].code
            self.ToCountryCode = selectedCountryCode
            let name = self.countries[index].name
            self.ToCountryTF.text = "(\(name))"
            print("Selected to Country Code: \(selectedCountryCode)")
        }
        FromTV.delegate = self
        ToCountryTF.delegate = self
        
        FromTV.text = placeholderText
        FromTV.textColor = UIColor.lightGray
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        FromTV.resignFirstResponder()
        ToTV.resignFirstResponder()
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        FromTV.textColor = .darkGray
            if textView.text == placeholderText {
                textView.text = ""
                textView.textColor = UIColor.darkGray
                
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholderText
                textView.textColor = UIColor.lightGray
            }
        }

    func setupSpeech() {
          Micbtn.isEnabled = false
          speechRecognizer = SFSpeechRecognizer() // Initialize without a locale for auto-detection
          speechRecognizer?.delegate = self
          
          SFSpeechRecognizer.requestAuthorization { (authStatus) in
              var isButtonEnabled = false
              switch authStatus {
              case .authorized:
                  isButtonEnabled = true
              case .denied, .restricted, .notDetermined:
                  isButtonEnabled = false
                  print("Speech recognition authorization failed with status: \(authStatus)")
              }
              
              OperationQueue.main.addOperation {
                  self.Micbtn.isEnabled = isButtonEnabled
              }
          }
      }
      
      func startRecording() {
          if recognitionTask != nil {
              recognitionTask?.cancel()
              recognitionTask = nil
          }
          
          let audioSession = AVAudioSession.sharedInstance()
          do {
              try audioSession.setCategory(.record, mode: .measurement, options: .defaultToSpeaker)
              try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
          } catch {
              print("Failed to set audio session properties.")
          }
          
          recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
          guard let recognitionRequest = recognitionRequest else {
              fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
          }
          
          recognitionRequest.shouldReportPartialResults = true
          
          let inputNode = audioEngine.inputNode
          recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in
              var isFinal = false
              if let result = result {
                  self.FromTV.text = result.bestTranscription.formattedString
                  isFinal = result.isFinal
              }
              
              if error != nil || isFinal {
                  self.audioEngine.stop()
                  inputNode.removeTap(onBus: 0)
                  self.recognitionRequest = nil
                  self.recognitionTask = nil
                  self.Micbtn.isEnabled = true
              }
          }
          
          let recordingFormat = inputNode.outputFormat(forBus: 0)
          inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
              self.recognitionRequest?.append(buffer)
          }
          
          audioEngine.prepare()
          do {
              try audioEngine.start()
          } catch {
              print("audioEngine couldn't start because of an error.")
          }
          
          FromTV.text = "Say something, I'm listening!"
      }
    func speak(text: String, languageCode: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set audio session category and mode
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session properties.")
        }
        
        speechSynthesizer.speak(utterance)
    }

    private func setupLottieAnimation() {
            // Create and configure the Lottie Animation View
            animationView = LottieAnimationView(name: "A1") // Make sure "v1.json" is in your project
            animationView.loopMode = .loop
            animationView.contentMode = .scaleAspectFit
            animationView.frame = CGRect(x: 150, y: 180, width: 100, height: 100) // Adjust the frame as needed
           // animationView.center = self.view.center // Center the animation view

            // Add the animation view to the view controller's view but keep it initially hidden
            self.view.addSubview(animationView)
            animationView.isHidden = true
        }
  
    @IBAction func Micbtn(_ sender: UIButton) {
        if audioEngine.isRunning {
                    // Stop recording
                    audioEngine.stop()
                    recognitionRequest?.endAudio()
                    Micbtn.isEnabled = false
                    Micbtn.setTitle("Start Recording", for: .normal)
                    // Stop the Lottie animation and hide the view
                    animationView.stop()
                    animationView.isHidden = true
                    isAnimationPlaying = false

                } else {
                    // Start recording
                    startRecording()
                    Micbtn.setTitle("Stop Recording", for: .normal)
                    // Show and start the Lottie animation
                    animationView.isHidden = false
                    animationView.play()
                    isAnimationPlaying = true
                }
    }
    @IBAction func translatebtn(_ sender: UIButton) {
        let fromText = FromTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
               
               // Check if the text view contains the placeholder or is empty
               if fromText.isEmpty || fromText == placeholderText {
                   showAlert(title: "Error!", message: "You Need To Record Something.")
                   return
               }
        
        if !FromTV.text.isEmpty  {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            SwiftyTranslate.translate(text: fromText ?? "", from: "", to: ToCountryCode) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    switch result {
                    case .success(let translation):
                        print("Translated: \(translation.translated)")
                        self.ToTV.text = translation.translated
                    case .failure(let error):
                        print("Error: \(error)")
                        self.showAlert(title: "Error!", message: "Translation failed. Please try again.")
                    }
                }
            }
        } else {
            showAlert(title: "Error!", message: "Please Select the Country First")
        }
    }
    
    @IBAction func Backbtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func FromspeakbtnPressed(_ sender: UIButton) {
        speak(text: FromTV.text, languageCode: ToCountryCode)
    }
    
    @IBAction func TospeakbtnPressed(_ sender: UIButton) {
        speak(text: ToTV.text, languageCode: ToCountryCode)
    }
    
  
    @IBAction func FromcopybtnPressed(_ sender: UIButton) {
        UIPasteboard.general.string = FromTV.text
        self.showToast(message: "Text Copied", font: .systemFont(ofSize: 14.0))
    }
    
    @IBAction func TocopybtnPressed(_ sender: UIButton) {
        UIPasteboard.general.string = ToTV.text
        self.showToast(message: "Text Copied", font: .systemFont(ofSize: 14.0))
    }

}

extension VoiceToTextViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.Micbtn.isEnabled = true
        } else {
            self.Micbtn.isEnabled = false
        }
    }
}
