//
//  ThroughCamDetectionVC.swift
//  SpeakScan Voice
//
//  Created by Moin Janjua on 06/09/2024.
//

import UIKit
import AVFoundation

class ThroughCamDetectionVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    func openCamera()
    {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
           activityIndicator.center = view.center
           activityIndicator.startAnimating()
           view.addSubview(activityIndicator)
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus
        {
         case .authorized:
        DispatchQueue.main.async
        { [weak self] in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
                self?.presentCamera()
        }
        case .notDetermined:
            
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            
        DispatchQueue.main.async
        {
            if granted
            {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self?.presentCamera()
            }
            else
            {
                self?.redirectToSettings()
            }
        }
        }
        case .denied, .restricted:
        redirectToSettings()
        @unknown default:
            break
        }
    }
    private func presentCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            print("Camera not available")
        }
    }

    private func redirectToSettings()
    {
        let alertController = UIAlertController(title: "Permission Required", message: "Please enable access to the camera or photo library in Settings.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        GoTodetailScreen(image: pickedImage)
       
    }
    func GoTodetailScreen(image:UIImage)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "OCRDEtailsViewController") as! OCRDEtailsViewController
        newViewController.selectedImage = image
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func CamerScanButton(_ sender: Any) {
        openCamera()
    }
    @IBAction func backbtnPressed(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }
}
