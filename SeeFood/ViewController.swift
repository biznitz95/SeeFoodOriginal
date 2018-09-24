//
//  ViewController.swift
//  SeeFood
//
//  Created by Bizet Rodriguez on 9/23/18.
//  Copyright © 2018 Bizet Rodriguez. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {fatalError("Error downcasting image to UIImage.")}
        
        imageView.image = userPickedImage
        
        guard let ciImage = CIImage(image: userPickedImage) else {
            fatalError("Could not convert UIImage to CIImage")
        }
        
        detect(image: ciImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Error obtaining CoreMLModel")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? Array<VNClassificationObservation> else {
                fatalError("Error converting results request into an array of VNClassificationObservation")
            }
            
            guard let firstResult = results.first else { fatalError("Error trying to get first results.")}
            
            if firstResult.identifier.contains("hotdog") {
                self.navigationItem.title = "Hotdog!"
            }
            else {
                self.navigationItem.title = "Not A Hotdog!"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print("Error thrown in handler, \(error)")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
}

