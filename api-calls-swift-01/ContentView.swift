//
//  ContentView.swift
//  api-calls-swift-01
//
//  Created by Antonio Vuono on 01/05/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            Text(user?.login ?? "username")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "bio")
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
                
                print(user ?? "user not found")
            } catch GHError.invalidURL {
                print("Invalid URL")
            } catch GHError.invalidResponse {
                print("Invalid response")
            } catch GHError.invalidData {
                print("Invalid data")
            } catch {
                print("Unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/antoniovuono"
        
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url )
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
