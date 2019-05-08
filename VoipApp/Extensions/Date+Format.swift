//
//  Date+Format.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import Foundation

extension NSDate {
    func formatToDefaultStyle() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm dd-mm-yyyy"
        return dateFormatter.string(from: self as Date)
    }
}
