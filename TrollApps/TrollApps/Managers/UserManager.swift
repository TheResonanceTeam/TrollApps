//
//  UserManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-15.
//

import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("reduced_motion") var reducedMotion : Bool = true
    @AppStorage("blur_strength") var blurStrength: Double = 10
    @AppStorage("compact_repo_view") var compactRepoView: Bool = false
    @AppStorage("lang") var lang : String = ""
    @AppStorage("add_repo_keyboard_type") var addRepoKeyboardType : UIKeyboardType = .URL
}
