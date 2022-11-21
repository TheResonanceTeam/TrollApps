//
//  JSONStuff.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import Foundation

struct stuff: Codable, Identifiable {
    var id: Int
    var title: String
    var description: String
    var url: String
    var bundleid: String
    var urlimg: String
    var completed: Bool
}

let decoder = JSONDecoder()
func FetchApps() async -> [stuff]? {
    do {
        let url = URL(string: "https://raw.githubusercontent.com/haxi0/TrollApps-Static-API/main/trollapps-0.3.1.json?token=")!
        let data = try await URLSession.shared.data(from: url).0
        return try decoder.decode([stuff].self, from: data)
    } catch {
        print("oopsie: \(error)")
        return nil
    }
}
