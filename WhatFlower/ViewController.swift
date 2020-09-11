//
//  ViewController.swift
//  WhatFlower
//
//  Created by Nishant Taneja on 11/09/20.
//  Copyright © 2020 Nishant Taneja. All rights reserved.
//

import UIKit
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage
import ColorThiefSwift

class ViewController: UIViewController {
    //MARK:- Initialise
    let imagePicker = UIImagePickerController()
    
    //MARK:- Override ViewLifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // ImagePicker Delegate
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
    //MARK:- IBOutlets|IBAction
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- Vision
    private func detectFlower(_ image: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {fatalError("error loading MLModel")}
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results?.first as? VNClassificationObservation else {fatalError("classification error")}
            let flowerName = result.identifier
            self.navigationItem.title = flowerName.capitalized
            self.requestDescription(for: flowerName)
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {try handler.perform([request])}
        catch {print(error)}
    }
    
    private func requestDescription(for flowerName: String) {
        let urlString = "https://en.wikipedia.org/w/api.php"
        let parameters: [String:String] = [
            "format": "json",
            "action": "query",
            "prop": "extracts|pageimages",
            "exintro": "",
            "explaintext": "",
            "titles": flowerName,
            "redirects": "1",
            "pithumbsize": "500",
            "indexpageids": ""
        ]
        Alamofire.request(urlString, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isFailure {print("HTTP Request error"); return}
            let data = JSON(response.result.value)
            self.parse(data)
        }
    }
    
    private func parse(_ data: JSON) {
        let pageId = data["query"]["pageids"][0].stringValue
        let flowerData = data["query"]["pages"][pageId]
        let description = flowerData["extract"].stringValue
        let imageUrlString = flowerData["thumbnail"]["source"].stringValue
        updateUIWith(description, imageUrlString)
    }
    
    private func updateUIWith(_ description: String, _ imageUrlString: String) {
        DispatchQueue.main.async {
            self.descriptionLabel.text = description
        }
    }
}

//MARK:- UIImagePickerController Delegate
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            guard let image = CIImage(image: selectedImage) else {fatalError("error converting UIImage to CIImage")}
            detectFlower(image)
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}

