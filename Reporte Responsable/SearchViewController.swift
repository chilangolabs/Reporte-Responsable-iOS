//
//  SearchViewController.swift
//  Reporte Responsable
//
//  Created by Rodrigo on 24/09/17.
//  Copyright © 2017 Chilango Labs. All rights reserved.
//

import Alamofire
import MapKit
import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var observationsLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.scrollView.keyboardDismissMode = .onDrag
        self.map.isZoomEnabled = false
        self.map.isScrollEnabled = false
        self.map.isUserInteractionEnabled = false
    }

    @IBAction func searchReport(_ sender: UIButton) {
        self.searchButton.isEnabled = false

        if (self.searchTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "Error", message: "Debes indicar tu número de reporte", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.searchButton.isEnabled = true
        } else {
            self.searchReport(reportId: self.searchTextField.text!, completion: { [unowned self] data in
                let status = Int((data["status"] as? String)!)
                switch status {
                case 1?:
                    self.statusLabel.text = ReportStatus.pending.title
                    self.statusLabel.textColor = ReportStatus.pending.color
                case 2?:
                    self.statusLabel.text = ReportStatus.checked.title
                    self.statusLabel.textColor = ReportStatus.checked.color
                case 3?:
                    self.statusLabel.text = ReportStatus.needPhysicCheck.title
                    self.statusLabel.textColor = ReportStatus.needPhysicCheck.color
                case 4?:
                    self.statusLabel.text = ReportStatus.urgentRevision.title
                    self.statusLabel.textColor = ReportStatus.urgentRevision.color
                default:
                    self.statusLabel.text = "Sin asignar"
                }
                
                self.nameLabel.text = data["contacto"] as? String
                self.phoneLabel.text = data["telefono"] as? String
                self.observationsLabel.text = data["observaciones"] as? String
                
                let latitude = CLLocationDegrees(Double((data["latitud"] as? String)!)!)
                let longitude = CLLocationDegrees(Double((data["longitud"] as? String)!)!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                self.photo.downloadedFrom(link: "https://criptexfc.com/tlalolin/img/\(data["foto"]!)")

                self.map.addAnnotation(annotation)
                self.map.showAnnotations([annotation], animated: true)
                
                self.contentView.isHidden = false
            })
        }
    }
}

extension SearchViewController {
    func searchReport(reportId: String, completion: @escaping ([String: Any]) -> Void) {
        Alamofire.request(IngRouter.search(reportId))
            .responseJSON { res in
                guard res.result.isSuccess else {
                    self.searchButton.isEnabled = true
                    print("Error while fetching tags: \(res.result.error)")
                    completion([String: Any]())
                    return
                }
                
                guard let responseJSON = res.result.value as? [String: Any],
                    let isValid = responseJSON["success"] as? Int else {
                        self.searchButton.isEnabled = true
                        print("Invalid tag information received from the service")
                        completion([String: Any]())
                        return
                }
                
                if isValid == 0 {
                    self.searchButton.isEnabled = true
                    let alert = UIAlertController(title: "Error", message: "Has ingresado un número de reporte inválido", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    guard let extra = responseJSON["extra"] as? [[String: Any]],
                        let data = extra.first else {
                            self.searchButton.isEnabled = true
                            let alert = UIAlertController(title: "Error", message: "Ocurrió un error, por favor intenta de nuevo", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                    }
                    
                    self.searchButton.isEnabled = true
                    completion(data)
                }
        }
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
