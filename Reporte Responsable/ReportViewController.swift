//
//  ReportViewController.swift
//  Reporte Responsable
//
//  Created by Rodrigo on 20/09/17.
//  Copyright © 2017 Chilango Labs. All rights reserved.
//

import Alamofire
import MapKit
import UIKit

class ReportViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var neighborhood: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var typeProperty: UITextField!
    @IBOutlet weak var damages: UITextField!
    @IBOutlet weak var damagesLocation: UITextField!
    @IBOutlet weak var levels: UITextField!
    @IBOutlet weak var habitants: UITextField!
    @IBOutlet weak var isEvacuated: UITextField!
    @IBOutlet weak var observations: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var elementPhoto: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var takeElementsPhotoButton: UIButton!
    @IBOutlet weak var sendReportButton: UIButton!
    
    weak var activeField: UITextField?
    
    let typePropertyDataSource: [(key: String, value: String)]  = [("hospital", "Hospital"), ("escuela", "Escuela"), ("estanciaInfantil", "Estancia Infantil"), ("depatamento", "Departamento"), ("casa", "Casa"), ("comercio", "Comercio"), ("oficinasPublicas", "Oficinas Públicas"), ("oficinasPrivadas", "Oficinas Privadas"), ("industria", "Industria"), ("centroDeReunion", "Centro de Reunión"), ("estacionamiento", "Estacionamiento"),
        ("recreativo", "Recreativo"), ("otro", "Otro")]
    let damagesDataSource: [(key: String, value: String)] = [("derrumbeTotal", "Derrumbe Total"), ("derrumbeParcial", "Derrumbe Parcial"), ("grietasMuros", "Grietas en Muros y Acabados"), ("grietasTrabes", "Grietas en Trabes y Columnas"), ("asentamiento", "Asentamiento o Hundimiento"), ("danoVidrios", "Daños en vidrios y cancelerías")]
    let damagesLocationDataSource: [(key: String, value: String)] = [("interior", "Interior"), ("exterior", "Exterior"), ("ambas", "Ambas")]
    let isEvacuatedDataSource: [(key: String, value: String)] = [("si", "Si"), ("no", "No"), ("parcialmente", "Parcialmente")]
    
    var imagePicked = 0
    var typePropertyData = ""
    var damagesData = ""
    var damagesLocationData = ""
    var isEvacuatedData = ""
    
    
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.scrollView.keyboardDismissMode = .onDrag
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.map.delegate = self
        self.map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        
        let addAnnotationTap = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        self.map.addGestureRecognizer(addAnnotationTap)
        
        // Toolbar para UIPickerView
        let toolbarPickerView = UIToolbar()
        let toolbarPickerViewFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let toolbarPickerViewOkButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerViewDone(_:)))
        toolbarPickerView.backgroundColor = .gray
        toolbarPickerView.sizeToFit()
        toolbarPickerView.setItems([toolbarPickerViewFlexSpace, toolbarPickerViewOkButton], animated: false)
        toolbarPickerView.isUserInteractionEnabled = true
        
        // Tipo de propiedad
        let typePropertyPickerView = UIPickerView()
        typePropertyPickerView.delegate = self
        typePropertyPickerView.tag = 1
        self.typeProperty.inputView = typePropertyPickerView
        self.typeProperty.inputAccessoryView = toolbarPickerView
        
        // Principal afectación
        let damagesPickerView = UIPickerView()
        damagesPickerView.delegate = self
        damagesPickerView.tag = 2
        self.damages.inputView = damagesPickerView
        self.damages.inputAccessoryView = toolbarPickerView
        
        // Ubicación del daño
        let damagesLocationPickerView = UIPickerView()
        damagesLocationPickerView.delegate = self
        damagesLocationPickerView.tag = 3
        self.damagesLocation.inputView = damagesLocationPickerView
        self.damagesLocation.inputAccessoryView = toolbarPickerView
        
        // Ya fue evacuado
        let isEvacuatedPickerView = UIPickerView()
        isEvacuatedPickerView.delegate = self
        isEvacuatedPickerView.tag = 4
        self.isEvacuated.inputView = isEvacuatedPickerView
        self.isEvacuated.inputAccessoryView = toolbarPickerView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchedView = touch.view
            if let _view = touchedView {
                if _view == view {
                    self.view.endEditing(true)
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return self.typePropertyDataSource.count
        case 2:
            return self.damagesDataSource.count
        case 3:
            return self.damagesLocationDataSource.count
        case 4:
            return self.isEvacuatedDataSource.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return self.typePropertyDataSource[row].value
        case 2:
            return self.damagesDataSource[row].value
        case 3:
            return self.damagesLocationDataSource[row].value
        case 4:
            return self.isEvacuatedDataSource[row].value
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            self.typeProperty.text = self.typePropertyDataSource[row].value
            self.typePropertyData = self.typePropertyDataSource[row].key
        case 2:
            self.damages.text = self.damagesDataSource[row].value
            self.damagesData = self.damagesDataSource[row].key
        case 3:
            self.damagesLocation.text = self.damagesLocationDataSource[row].value
            self.damagesLocationData = self.damagesLocationDataSource[row].key
        case 4:
            self.isEvacuated.text = self.isEvacuatedDataSource[row].value
            self.isEvacuatedData = self.isEvacuatedDataSource[row].key
        default:
            break
        }
    }
    
    @objc func pickerViewDone (_ sender: UIBarButtonItem) {
        self.typeProperty.resignFirstResponder()
        self.damages.resignFirstResponder()
        self.damagesLocation.resignFirstResponder()
        self.isEvacuated.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
    }
    
    @objc func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func setUpKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains((self.activeField?.frame.origin)!)) {
                self.scrollView.scrollRectToVisible((self.activeField?.frame)!, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let photoTaken = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if imagePicked == 1 {
            self.photo.image = photoTaken
        } else if imagePicked == 2 {
            self.elementPhoto.image = photoTaken
        }
        
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
        self.imagePicked = sender.tag
        
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
        if (self.contact.text?.isEmpty)! || (self.phone.text?.isEmpty)! || (self.phone.text?.isEmpty)! || (self.observations.text?.isEmpty)! || (self.street.text?.isEmpty)! || (self.number.text?.isEmpty)! || (self.neighborhood.text?.isEmpty)! || (self.city.text?.isEmpty)! || (self.zipCode.text?.isEmpty)! || (self.typeProperty.text?.isEmpty)! || (self.damages.text?.isEmpty)! || (self.damagesLocation.text?.isEmpty)! || (self.levels.text?.isEmpty)! || (self.habitants.text?.isEmpty)! || (self.isEvacuated.text?.isEmpty)! || self.photo.image == nil || self.elementPhoto.image == nil {
            let alert = UIAlertController(title: "Error", message: "Debes completar todos los campos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.takePhotoButton.isEnabled = false
            self.takeElementsPhotoButton.isEnabled = false
            self.sendReportButton.isEnabled = false
            self.upload(image: [self.photo.image!, self.elementPhoto.image!], progressCompletion: {percent in
                
                }, completion: {reportId in
                    self.cleanAllData()
                    
                    let alert = UIAlertController(title: "", message: "Gracias por tu reporte\nTu número de reporte es: \(reportId)\nRecuerda guardarlo en un lugar seguro", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func cleanAllData () -> Void {
        self.contact.text = ""
        self.phone.text = ""
        self.email.text = ""
        self.street.text = ""
        self.number.text = ""
        self.neighborhood.text = ""
        self.city.text = ""
        self.zipCode.text = ""
        self.typeProperty.text = ""
        self.damages.text = ""
        self.damagesLocation.text = ""
        self.levels.text = ""
        self.habitants.text = ""
        self.isEvacuated.text = ""
        self.observations.text = ""
        self.photo.image = nil
        self.map.removeAnnotations(self.map.annotations)
        self.takePhotoButton.isEnabled = true
        self.takeElementsPhotoButton.isEnabled = true
        self.sendReportButton.isEnabled = true
    }
    
}

extension ReportViewController {
    func upload(image: [UIImage], progressCompletion: @escaping (_ percent: Float) -> Void, completion: @escaping(_ response: String) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image[0], 0.7),
        let imageElementsData = UIImageJPEGRepresentation(image[1], 0.7) else {
            print("Error: Could not get JPEG representation for UIImage")
            return
        }
        
        Alamofire.upload(multipartFormData: {multipartFormData in
            multipartFormData.append((self.contact.text?.data(using: String.Encoding.utf8))!, withName: "contacto")
            multipartFormData.append((self.phone.text?.data(using: String.Encoding.utf8))!, withName: "telefono")
            multipartFormData.append((self.email.text?.data(using: String.Encoding.utf8))!, withName: "correo")
            multipartFormData.append((self.street.text?.data(using: String.Encoding.utf8))!, withName: "calle")
            multipartFormData.append((self.number.text?.data(using: String.Encoding.utf8))!, withName: "numero")
            multipartFormData.append((self.neighborhood.text?.data(using: String.Encoding.utf8))!, withName: "colonia")
            multipartFormData.append((self.city.text?.data(using: String.Encoding.utf8))!, withName: "municipio")
            multipartFormData.append((self.zipCode.text?.data(using: String.Encoding.utf8))!, withName: "cp")
            multipartFormData.append((self.typePropertyData.data(using: String.Encoding.utf8))!, withName: "tipo")
            multipartFormData.append((self.damagesData.data(using: String.Encoding.utf8))!, withName: "afectaciones")
            multipartFormData.append((self.damagesLocationData.data(using: String.Encoding.utf8))!, withName: "ubicacion")
            multipartFormData.append((self.levels.text?.data(using: String.Encoding.utf8))!, withName: "niveles")
            multipartFormData.append((self.habitants.text?.data(using: String.Encoding.utf8))!, withName: "residentes")
            multipartFormData.append((self.isEvacuatedData.data(using: String.Encoding.utf8))!, withName: "evacuado")
            multipartFormData.append((self.observations.text?.data(using: String.Encoding.utf8))!, withName: "observaciones")
            multipartFormData.append(String(self.map.annotations[0].coordinate.latitude).data(using: String.Encoding.utf8)!, withName: "latitud")
            multipartFormData.append(String(self.map.annotations[0].coordinate.longitude).data(using: String.Encoding.utf8)!, withName: "longitud")
            multipartFormData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
            multipartFormData.append(imageElementsData, withName: "file_elementos", fileName: "file_elementos.jpg", mimeType: "image/jpeg")
        }, with: IngRouter.report, encodingCompletion: {encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    progressCompletion(Float(progress.fractionCompleted))
                }
                upload.validate()
                upload.responseJSON {response in
                    guard response.result.isSuccess else {
                        print("Error while uploading file: \(String(describing: response.result.error))")
                        completion(String())
                        return
                    }
                    
                    guard let responseJSON = response.result.value as? [String: Any],
                        let isValid = responseJSON["success"] as? Int else {
                            print("Invalid information received from service")
                            completion(String())
                            return
                    }
                    
                    if isValid == 0 {
                        let alert = UIAlertController(title: "Error", message: "Ocurrio un error, intenta de nuevo", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        guard let reportId = responseJSON["random_id"] as? String else {
                            return
                        }
                        
                        completion(reportId)
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
}
