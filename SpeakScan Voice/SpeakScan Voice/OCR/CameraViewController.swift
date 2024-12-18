//
//  CameraViewController.swift
//  LinguaLens
//
//  Created by Unique Consulting Firm on 29/06/2024.
//

import UIKit
import Photos

class CameraViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func cameratbtnPressed(_ sender:UIButton)
    {
        openCamera()
    }
    @IBAction func gallerybtnPressed(_ sender:UIButton)
    {
        openGallery()
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
        
    func openGallery()
    {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
           activityIndicator.center = view.center
           activityIndicator.startAnimating()
           view.addSubview(activityIndicator)
        
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoLibraryAuthorizationStatus {
        case .authorized:
            DispatchQueue.main.async { [weak self] in
                self?.presentImagePicker(with: activityIndicator)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async
                {
                    if status == .authorized
                    {
                        self?.presentImagePicker(with: activityIndicator)
                    } else {
                        self?.redirectToSettings()
                    }
                }
            }
        case .denied, .restricted:
            redirectToSettings()
        case .limited:
            // Handle limited photo library access if needed
            break
        @unknown default:
            break
        }
    }
    
    private func presentImagePicker(with activityIndicator: UIActivityIndicatorView) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true) {
            // Dismiss the activity indicator once the gallery is presented
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
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
    
    @IBAction func backbtnPressed(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }

}
