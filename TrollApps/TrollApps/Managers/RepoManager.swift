//
//  RepoManager.swift
//  TrollApps
//
//  Created by Cleopatra on 2023-12-02.
//

import SwiftUI

// https://medium.com/swlh/decoding-a-json-field-that-could-be-string-or-double-with-swift-f6ea6a2babf8
enum StringOrDouble: Decodable, Encodable, Equatable {
    case string(String)
    case double(Double)

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            if let double = try? container.decode(Double.self) {
                self = .double(double)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else {
                throw Error.couldNotFindStringOrDouble
            }
        } catch {
            throw Error.couldNotFindStringOrDouble
        }
    }

    enum Error: Swift.Error {
        case couldNotFindStringOrDouble
    }
    
    func toString() -> String {
        switch self {
        case .string(let stringValue):
            return stringValue
        case .double(let doubleValue):
            return String(doubleValue)
        }
    }
}

struct Repo: Decodable, Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String?
    var iconURL: String?
    var headerURL: String?
    var featuredApps: [String]?
    var tintColor: String?
    var apps: [Application]
    var news: [News]?
}

struct RepoMemory: Identifiable {
    let id = UUID()
    var url: String
    var data: Repo
}

struct BadRepoMemory: Identifiable {
    let id = UUID()
    var url: String
}

struct ErrorMemory: Identifiable {
    let id = UUID()
    var url: String
    var data: Repo
}

struct Version: Codable, Equatable {
    var absoluteVersion: String?
    var version: String
    var date: String
    var localizedDescription: String?
    var downloadURL: String
    var size: StringOrDouble?
    var minOSVersion: String?
    var maxOSVersion: String?
}

struct News: Codable, Identifiable, Hashable {
    var id = UUID()
    var title : String?
    var caption: String?
    var date: String?
    var tintColor: String?
    var imageURL: String?
    var url: String?
    var appID: String?
}

struct Application: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var subtitle: String?
    var bundleIdentifier: String?
    var version: String?
    var versionDate: String?
    var size: StringOrDouble?
    var downloadURL: String?
    var developerName: String?
    var localizedDescription: String?
    var tintColor: String?
    var iconURL: String
    var screenshotURLs: [String]?
    var versions: [Version]?

    enum CodingKeys: String, CodingKey {
        case name, subtitle, bundleIdentifier, version, versionDate, size, downloadURL, developerName, localizedDescription, tintColor, iconURL, screenshotURLs, versions
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

let decoder = JSONDecoder()

class RepositoryManager: ObservableObject {
    @AppStorage("repos") var RepoList: [String] = [
        "https://raw.githubusercontent.com/TheResonanceTeam/.default-sources/main/haxi0_2.0.json",
        "https://raw.githubusercontent.com/TheResonanceTeam/.default-sources/main/BonnieRepo_2.0.json",
        "https://raw.githubusercontent.com/TheResonanceTeam/.default-sources/main/ResonanceTeamRepo.json"
    ]
    @Published var ReposData: [RepoMemory] = []
    @Published var BadRepos: [BadRepoMemory] = []
    @Published var InstalledApps = GetApps()
    
    @Published var hasFetchedRepos: Bool = false
    @Published var hasFinishedFetchingRepos: Bool = false
    
    @Published var isInstallingApp = false
    @Published var isDownloadingApp = false
    
    
    func fetchRepos() {
        self.hasFetchedRepos = true
        fetchRepos(RepoList) { fetchedResults, errors in
            self.ReposData = fetchedResults
            self.BadRepos = errors
            
            self.hasFinishedFetchingRepos = true
        }
    }
    
    func addRepo(_ repoURL: String, alertManager: AlertManager, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        if !RepoList.contains(repoURL.trimmingCharacters(in: .whitespacesAndNewlines)) {
            dispatchGroup.enter()
            
            let regex = try! NSRegularExpression(pattern: #"^repo\[[A-Za-z0-9+/]+={0,2}\]$"#, options: .caseInsensitive)
            
            let range = NSRange(location: 0, length: repoURL.utf16.count)
            let isMatch = regex.firstMatch(in: repoURL, options: [], range: range) != nil
            
            if isMatch {
                if let base64String = repoURL.components(separatedBy: "[").last?.components(separatedBy: "]").first,
                   let data = Data(base64Encoded: base64String),
                   let decodedString = String(data: data, encoding: .utf8) {
                    var urlArray = decodedString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                    urlArray = urlArray.filter { !self.RepoList.contains($0) }
                    
                    fetchRepos(urlArray) { fetchedResults, errors in
                        self.ReposData = self.ReposData + fetchedResults
                        self.BadRepos = self.BadRepos + errors
                        self.RepoList = self.RepoList + urlArray
                        
                        dispatchGroup.leave()
                    }
                } else {
                    alertManager.showAlert(
                        title: Text(LocalizedStringKey("ERROR_DECODING_BASE64_STRING")),
                        body: Text(LocalizedStringKey("PLEASE_VERIFY_VALID_REPO_STRING"))
                    )
                }
            } else {
                fetchRepos([repoURL]) { fetchedResults, errors in
                    self.ReposData = self.ReposData + fetchedResults
                    self.BadRepos = self.BadRepos + errors
                    self.RepoList = self.RepoList + [repoURL.trimmingCharacters(in: .whitespacesAndNewlines)]
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion()
            }
        } else {
            completion()
        }
    }
    
    func removeRepos(repoIds: Set<UUID>) {
        for repoId in repoIds {
            if let reposIndex = ReposData.firstIndex(where: { $0.id == repoId }) {
                if let repoListIndex = RepoList.firstIndex(of: ReposData[reposIndex].url) {
                    RepoList.remove(at: repoListIndex)
                }
                ReposData.remove(at: reposIndex)
            }
        }
    }
    
    func removeBadRepos(repoIds: Set<UUID>) {
        for repoId in repoIds {
            if let badReposIndex = BadRepos.firstIndex(where: { $0.id == repoId }) {
                if let repoListIndex = RepoList.firstIndex(of: BadRepos[badReposIndex].url) {
                    RepoList.remove(at: repoListIndex)
                }
                BadRepos.remove(at: badReposIndex)
            }
        }
    }
    
    func fetchRepo(_ repoURL: String, completion: @escaping (Result<Repo, Error>) -> Void) {
        
        var modifiedRepoURL = repoURL
        
        if !repoURL.contains("://") {
            modifiedRepoURL = "https://\(repoURL)"
        }
        
        guard let url = URL(string: modifiedRepoURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.unknown)))
                return
            }
            
            do {
                var decodedRepo = try decoder.decode(Repo.self, from: data)
                
                for index in decodedRepo.apps.indices {
                    let app = decodedRepo.apps[index]
                    
                    if app.downloadURL != nil {
                        let builtVersion = Version(
                            version: app.version ?? "",
                            date: app.versionDate ?? "",
                            localizedDescription: app.localizedDescription ?? "",
                            downloadURL: app.downloadURL ?? "",
                            size: app.size ?? nil
                        )
                        
                        if app.versions == nil {
                            decodedRepo.apps[index].versions = []
                        }
                        
                        decodedRepo.apps[index].versions?.insert(builtVersion, at: 0)
                    }
                }
                
                completion(.success(decodedRepo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchRepo(_ repoURL: String, completion: @escaping (Repo?) -> Void) {
        fetchRepo(repoURL) { result in
            switch result {
            case .success(let repo):
                completion(repo)
            case .failure(let error):
                print("Oopsie: \(error)")
                completion(nil)
            }
        }
    }
    
    func fetchRepo(_ repoURL: String) -> Repo? {
        var result: Repo?
        let semaphore = DispatchSemaphore(value: 0)
        
        fetchRepo(repoURL) { repo in
            result = repo
            semaphore.signal()
        }
        
        semaphore.wait()
        
        
        return result
    }
    
    func fetchRepos(_ repoURLs: [String], completion: @escaping ([RepoMemory], [BadRepoMemory]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var results: [RepoMemory] = []
        var errors: [BadRepoMemory] = []
        
        for repoURL in repoURLs {
            dispatchGroup.enter()
            
            fetchRepo(repoURL.trimmingCharacters(in: .whitespacesAndNewlines)) { result in
                if let unwrappedResult = result {
                    let outputRepoMemory = RepoMemory(
                        url: repoURL.trimmingCharacters(in: .whitespacesAndNewlines),
                        data: unwrappedResult
                    )
                    results.append(outputRepoMemory)
                } else {
                    let outputBadRepoMemory = BadRepoMemory(
                        url: repoURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    errors.append(outputBadRepoMemory)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results, errors)
        }
    }
    
    func IsAppInstalled(_ BundleID: String) -> Bool {
        let installedApps = InstalledApps
        return installedApps.contains { $0.id == BundleID }
    }
        
    func IsTrollStoreManaged(_ BundleID: String) -> Bool {
        let installedApps = InstalledApps
        if let installedApp = installedApps.first(where: { $0.id == BundleID }) {
            return installedApp.isTrollStore
        } else {
            return false
        }
    }
    
    func showUpdateButton(version1: String, BundleID: String) -> Int32 {
        let installedApps = InstalledApps
        if let installedApp = installedApps.first(where: { $0.id == BundleID }) {
            if (installedApp.version == version1) {
                return 0
            } else {
                return compareVersions(version1, installedApp.version) ? 1 : 2
            }
        } else {
            return 0
        }
    }
    
    func fetchAppsInRepo(repoInput: Repo, bundleIdInput: String) -> [Application] {
        return repoInput.apps.filter { $0.bundleIdentifier == bundleIdInput }
    }
}
