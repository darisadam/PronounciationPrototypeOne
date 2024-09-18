//
//  ContentView.swift
//  PronounciationPrototypeOne
//
//  Created by Adam Daris Ryadhi on 30/07/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var chatMessage = ""
    @State private var chatResponses: [String] = []
    @State private var isSending = false
    
    private let chatClient = ChatGPTClient()
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(chatResponses, id: \.self) { response in
                    ChatBubble(response: response)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            HStack {
                Button(action: {
                    if !isRecording {
                        speechRecognizer.transcribe()
                    } else {
                        speechRecognizer.stopTranscribing()
                        sendMessage()
                    }
                    isRecording.toggle()
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .onChange(of: speechRecognizer.transcript) { newTranscript in
            chatMessage = newTranscript
        }
    }
    
    private func sendMessage() {
        guard !chatMessage.isEmpty else { return }
        isSending = true
        
        chatClient.sendMessage(chatMessage) { response in
            DispatchQueue.main.async {
                chatResponses.append("You: \(chatMessage)")
                chatResponses.append("Parrotalk: \(response)")
                chatMessage = ""
                isSending = false
                
                speak(response) // Membaca hasil tanggapan dari ChatGPT
            }
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Mengatur kecepatan suara
        synthesizer.speak(utterance)
    }
}

struct ChatBubble: View {
    var response: String
    
    var body: some View {
        HStack {
            if response.starts(with: "You:") {
                Spacer()
                Text(response)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(.primary)
            } else {
                Text(response)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
