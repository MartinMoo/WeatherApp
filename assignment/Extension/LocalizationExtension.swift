//
//  LocalizationExtension.swift
//  assignment
//
//  Created by Martin Miklas on 27/01/2021.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        let localized = NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "")
        
        // If string not in current locale, return default english locale
        if localized == self {
            let path = Bundle.main.path (forResource: "en", ofType: "lproj")
            let languageBundle = Bundle (path: path!)
            return languageBundle!.localizedString(forKey: self, value: "", table: nil)
        }
        return localized
    }
}
