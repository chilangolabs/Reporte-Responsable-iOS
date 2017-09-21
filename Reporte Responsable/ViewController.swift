//
//  ViewController.swift
//  Reporte Responsable
//
//  Created by Rodrigo on 20/09/17.
//  Copyright © 2017 Chilango Labs. All rights reserved.
//

import Alamofire
import MapKit
import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var observations: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var sendReportButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.map.delegate = self
        self.map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        
        let addAnnotationTap = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        self.map.addGestureRecognizer(addAnnotationTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let photoTaken = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.photo.image = photoTaken
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != .authorizedWhenInUse) {
            manager.requestWhenInUseAuthorization()
        } else if (status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }

    @IBAction func capturePhoto(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func addAnnotation(_ sender: UIGestureRecognizer) -> Void {
        let point = self.map.convert(sender.location(in: self.map), toCoordinateFrom: self.map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = point
        self.map.removeAnnotations(self.map.annotations)
        self.map.addAnnotation(annotation)
    }
    
    @IBAction func sendReport(_ sender: UIButton) -> Void {
        if (self.contact.text?.isEmpty)! || (self.phone.text?.isEmpty)! || (self.observations.text?.isEmpty)! || self.photo.image == nil {
            let alert = UIAlertController(title: "Error", message: "Debes completar todos los campos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.takePhotoButton.isEnabled = false
            self.sendReportButton.isEnabled = false
            self.upload(image: self.photo.image!, progressCompletion: {percent in
                
                }, completion: {response in
                    self.cleanAllData()
                    
                    let alert = UIAlertController(title: "", message: "Gracias por tu reporte", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func cleanAllData () -> Void {
        self.contact.text = ""
        self.phone.text = ""
        self.observations.text = ""
        self.photo.image = nil
        self.map.removeAnnotations(self.map.annotations)
        self.takePhotoButton.isEnabled = true
        self.sendReportButton.isEnabled = true
    }
    
}

extension ViewController {
    func upload(image: UIImage, progressCompletion: @escaping (_ percent: Float) -> Void, completion: @escaping(_ response: [String]) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.9) else {
            print("Error: Could not get JPEG representation for UIImage")
            return
        }
        
        Alamofire.upload(multipartFormData: {multipartFormData in
            multipartFormData.append((self.contact.text?.data(using: String.Encoding.utf8))!, withName: "contacto")
            multipartFormData.append((self.phone.text?.data(using: String.Encoding.utf8))!, withName: "telefono")
            multipartFormData.append((self.observations.text?.data(using: String.Encoding.utf8))!, withName: "observaciones")
            multipartFormData.append(String(self.map.annotations[0].coordinate.latitude).data(using: String.Encoding.utf8)!, withName: "latitud")
            multipartFormData.append(String(self.map.annotations[0].coordinate.longitude).data(using: String.Encoding.utf8)!, withName: "longitud")
            multipartFormData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
        }, with: IngRouter.report, encodingCompletion: {encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    progressCompletion(Float(progress.fractionCompleted))
                }
                upload.validate()
                upload.responseJSON {response in
                    print("Respuesta: \(response)")
                    
                    guard response.result.isSuccess else {
                        print("Error while uploading file: \(String(describing: response.result.error))")
                        completion([String]())
                        return
                    }
                    
                    guard let responseJSON = response.result.value as? [String: Any],
                    let extra = responseJSON["extra"] as? [String: Any] else {
                        print("Invalid information received from service")
                        completion([String]())
                        return
                    }
                    
                    print("Extra: \(extra)")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
}
