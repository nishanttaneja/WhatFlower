//
//  ViewController.swift
//  WhatFlower
//
//  Created by Nishant Taneja on 11/09/20.
//  Copyright © 2020 Nishant Taneja. All rights reserved.
//

import UIKit

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
    private func detectFlower(_ image: CIImage) {}
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

