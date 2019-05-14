//
//  String+Format.swift
//  VoipApp
//
//  Created by Luis  Costa on 14/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import Foundation

extension String {
    func formatAsPhoneNumber() -> String {
        let numbers = "1234567890+"
        return String(self.filter { numbers.contains($0) })
    }
}
