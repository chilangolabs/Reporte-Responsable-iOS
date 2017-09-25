//
//  ReportStatus.swift
//  Reporte Responsable
//
//  Created by Rodrigo on 24/09/17.
//  Copyright © 2017 Chilango Labs. All rights reserved.
//

import UIKit

public enum ReportStatus {
    case pending
    case checked
    case needPhysicCheck
    case urgentRevision
    
    var color: UIColor {
        switch self {
        case .pending:
            return UIColor(red: 0, green: 0.6, blue: 0.8, alpha: 1)
        case .checked:
            return UIColor(red: 0.4, green: 0.6, blue: 0, alpha: 1)
        case .needPhysicCheck:
            return UIColor(red: 1, green: 0.53, blue: 0, alpha: 1)
        case .urgentRevision:
            return UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var title: String {
        switch self {
        case .pending:
            return "Pendiente"
        case .checked:
            return "Revisado"
        case .needPhysicCheck:
            return "Requiere revisión física"
        case .urgentRevision:
            return "Urgente revisión"
        }
    }
}
