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
    var selectedImage: UIImage?
    
    //MARK:- Override ViewLifecycle Method
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = ColorThief.getColor(from: imageView.image!)?.makeUIColor()
    }
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
    /// This function performs the classification task for the user-selected image. This function identifies the name of the selected flower using a Flower Classifier MLModel.
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
    //MARK:- Networking
    /// This function performs a request using Alamofire to fetch Data from the Internet. Alamofire is a framework which is used for Networking.
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
            if response.result.isFailure {print("connection issues"); return}
            let data = JSON(response.result.value)
            self.parse(data)
        }
    }
    /// This function parses JSON data using SwiftyJSON. SwiftyJSON is a framework which is used for JSON data parsing.
    private func parse(_ data: JSON) {
        let pageId = data["query"]["pageids"][0].stringValue
        let flowerData = data["query"]["pages"][pageId]
        let description = flowerData["extract"].stringValue
        let imageUrlString = flowerData["thumbnail"]["source"].stringValue
        updateUIWith(description, imageUrlString)
    }
    
    //MARK:- UI Customisation
    /// This function updates the UI with freshly fetched data from Internet. Updates description and image. If no image is available then user selected image is displayed.
    private func updateUIWith(_ description: String, _ imageUrlString: String) {
        descriptionLabel.text = description
        imageView.sd_setImage(with: URL(string: imageUrlString)) { (image, error, cache, url) in
            guard let fetchedImage = image else {
                print("error loading image")
                self.imageView.image = self.selectedImage
                return
            }
            if let dominantColor = ColorThief.getColor(from: fetchedImage) {
                DispatchQueue.main.async {self.view.backgroundColor = dominantColor.makeUIColor()}
            }
            else {print("can't get dominant color")}
        }
    }
}

//MARK:- UIImagePickerController Delegate
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.selectedImage = selectedImage
            guard let image = CIImage(image: selectedImage) else {fatalError("error converting UIImage to CIImage")}
            detectFlower(image)
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}

