//
//  UserSettings.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-12.
//

import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("reduced_motion") var reducedMotion : Bool = true
    @AppStorage("lang") var lang : String = ""
}
