//
//  RepoManager.swift
//  TrollApps
//
//  Created by Cleo Debeau on 2023-12-02.
//

import SwiftUI

struct Repo: Decodable, Identifiable, Equatable {
    let id = UUID()
    var name: String?
    var icon: String?
    var featuredApps: [String]?
    var apps: [Application]
}

struct RepoMemory: Identifiable {
    let id = UUID()
    var url: String
    var data: Result<Repo, Error>
}

struct Version: Codable, Equatable {
    var version: String
    var date: String
    var localizedDescription: String?
    var downloadURL: String
    var size: Int32?
    var minOSVersion: String?
    var maxOSVersion: String?
}

struct Application: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var bundleIdentifier: String
    var version: String?
    var versionDate: String?
    var size: Int32?
    var downloadURL: String?
    var developerName: String
    var localizedDescription: String
    var iconURL: String
    var featured: Bool?
    var screenshotURLs: [String]?
    var versions: [Version]?

    enum CodingKeys: String, CodingKey {
        case name, bundleIdentifier, version, versionDate, size, downloadURL, developerName, localizedDescription, iconURL, featured, screenshotURLs, versions
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

let decoder = JSONDecoder()

class RepositoryManager: ObservableObject {
    @AppStorage("repos") var RepoList: [String] = ["https://raw.githubusercontent.com/Cleover/TrollStore-IPAs/main/apps.json"]
    @Published var ReposData: [RepoMemory] = []
    @Published var hasFetchedRepos: Bool = false

    func fetchRepos() {
        fetchRepos(RepoList) { fetchedResults in
            self.ReposData = fetchedResults
            self.hasFetchedRepos = true
        }
    }

    func addRepo(_ repoURL: String, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()

        fetchRepo(repoURL) { result in
            DispatchQueue.main.async {
                self.RepoList.append(repoURL)
                
                let outputRepoMemory = RepoMemory(
                    url: repoURL,
                    data: result
                )
                
                self.ReposData.append(outputRepoMemory)

                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    func removeRepo(repoMemory: RepoMemory) {
        if let index = RepoList.firstIndex(of: repoMemory.url) {
            RepoList.remove(at: index)
         }
        
        if let index = ReposData.firstIndex(where: { $0.id == repoMemory.id }) {
            ReposData.remove(at: index)
        }
    }
    
    func fetchRepo(_ repoURL: String, completion: @escaping (Result<Repo, Error>) -> Void) {
                
        guard let url = URL(string: repoURL) else {
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
                let decodedRepo = try decoder.decode(Repo.self, from: data)
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

    func fetchRepos(_ repoURLs: [String], completion: @escaping ([RepoMemory]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var results: [RepoMemory] = []
        
        for repoURL in repoURLs {
            dispatchGroup.enter()

            fetchRepo(repoURL) { result in
                
                let outputRepoMemory = RepoMemory(
                    url: repoURL,
                    data: result
                )

                results.append(outputRepoMemory)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
}
