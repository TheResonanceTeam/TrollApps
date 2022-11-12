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
    var link: String
    var prevlink: String
    var urlimg: String
    var completed: Bool
}

class fetchtd: ObservableObject {
    @Published var jsonstuff = [stuff]()
    
    init() {
        let url = URL(string: "https://haxi0-dev.com/api/trollapps-0.1.json")!
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let jsondata = data {
                    let decodeddata = try JSONDecoder().decode([stuff].self, from: jsondata)
                    DispatchQueue.main.async {
                        self.jsonstuff = decodeddata
                    }
                } else {
                    print("no data")
                }
            } catch {
                print("oopsie")
            }
        }.resume()
    }
}
