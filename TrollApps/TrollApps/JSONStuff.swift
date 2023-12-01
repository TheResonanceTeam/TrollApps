import Foundation

struct stuff: Codable, Identifiable {
    var id = UUID()
    var name: String
    var bundleIdentifier: String
    var version: String
    var versionDate: String
    var size: Int32
    var downloadURL: String
    var developerName: String
    var localizedDescription: String
    var iconURL: String
    var featured: Bool?
    var screenshotURLs: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name, bundleIdentifier, version, versionDate, size, downloadURL, developerName, localizedDescription, iconURL, featured, screenshotURLs
    }
}

let decoder = JSONDecoder()

// TODO: Fetch "featuredApps" from the repo list, rather then checking each app for the "featured: true" property as to conform more with the AltStore repo standard


func FetchFeaturedApps() async -> [stuff]? {
    do {
        let url = URL(string: "https://raw.githubusercontent.com/Cleover/TrollStore-IPAs/main/apps.json")!
        let data = try await URLSession.shared.data(from: url).0
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        if let appsArray = json?["apps"] as? [[String: Any]] {
            let apps = try decoder.decode([stuff].self, from: JSONSerialization.data(withJSONObject: appsArray))
            
            // Return only the featured apps (or treat missing 'featured' as false)
            let featuredApps = apps.filter { $0.featured ?? false }
            return featuredApps
        } else {
            print("Error: Unable to extract 'apps' array from JSON.")
            return nil
        }
    } catch {
        print("Oopsie: \(error)")
        return nil
    }
}

