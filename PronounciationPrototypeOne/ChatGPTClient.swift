//
//  File.swift
//  PronounciationPrototypeOne
//
//  Created by Adam Daris Ryadhi on 01/08/24.
//

import Foundation

class ChatGPTClient {
    private let apiKey = "your API-key"
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func sendMessage(_ message: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": message]]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion("An error occurred")
                return
            }
            
            if let response = try? JSONDecoder().decode(ChatGPTResponse.self, from: data) {
                completion(response.choices.first?.message.content ?? "No response")
            } else {
                completion("Failed to parse response")
            }
        }
        
        task.resume()
    }
}

struct ChatGPTResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
