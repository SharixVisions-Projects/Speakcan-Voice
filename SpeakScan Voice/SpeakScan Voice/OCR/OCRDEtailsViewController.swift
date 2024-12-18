//
//  OCRDEtailsViewController.swift
//  LinguaLens
//
//  Created by Unique Consulting Firm on 29/06/2024.
//

import UIKit
import Vision

class OCRDEtailsViewController: UIViewController {

    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var detecTextView:UITextView!
    
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = selectedImage
        detecTextView.isHidden = true
    }
    
    func recognizeText(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var recognizedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + "\n"
            }
            DispatchQueue.main.async {
                
                if recognizedText == "" {
                    self.detecTextView.text = "No Text Found in Image. Try! another image"
                    let alert = UIAlertController(title: "Recognition Error", message: "No Text Found in Image. Try! another image", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.detecTextView.text = recognizedText
                    self.detecTextView.isHidden = false
                }
            }
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    
    
    @IBAction func scanbtnPressed(_ sender:UIButton)
    {
        recognizeText(image: selectedImage)
    }
    
    @IBAction func copybtnPressed(_ sender:UIButton)
    {
        copyText()
    }
    @IBAction func ShareBtn(_ sender: Any) {
        shareDetectedText()
    }
    
    @IBAction func backbtnPressed(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }

    func copyText()
    {
       print("gdghgfd")
        if !detecTextView.text.isEmpty
       {
        
           UIPasteboard.general.string = detecTextView.text
            detecTextView.text = ""
           let alert = UIAlertController(title: "Text Copied", message: "Text has been copied to clipboard", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
           return
       }
     
       let alert = UIAlertController(title: "Alert!", message: "Looks like text field is empty", preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
       present(alert, animated: true, completion: nil)
   }
    func shareDetectedText() {
        // Check if there is text to share
        guard let textToShare = detecTextView.text, !textToShare.isEmpty else {
            // Show an alert if there's no text to share
            let alert = UIAlertController(title: "No Text to Share", message: "Please scan an image to recognize text before sharing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Create an activity view controller with the detected text
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        // Exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [.postToFacebook, .postToTwitter]
        
        // Present the activity view controller
        present(activityViewController, animated: true, completion: nil)
    }

}
