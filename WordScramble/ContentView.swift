//
//  ContentView.swift
//  WordScramble
//
//  Created by Carlos Ramirez on 5/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        Text(rootWord)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Text("Score : \(score)")
                    }
                    .padding(.horizontal)
                    
                    List {
                        Section {
                            TextField("Enter your word", text: $newWord)
                                .textInputAutocapitalization(.never)
                            
                        }
                        
                        Section {
                            ForEach(usedWords, id: \.self) { word in
                                HStack {
                                    Image(systemName: "\(word.count).circle")
                                    Text(word)
                                }
                            }
                        }
                    }
                    .onSubmit(addNewWord)
                    .onAppear(perform: startGame)
                    .scrollContentBackground(.hidden)
                    .padding(.top, -25)
                    .alert(errorTitle, isPresented: $showingError) {
                        Button("OK") { }
                    } message: {
                        Text(errorMessage)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("New Game") {
                                startGame()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not real", message: "That isn't a real word.")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word must be longer than 3 characters", message: "Way too short")
            return
        }
        
        guard isNotSameAsRoot(word: answer) else {
            wordError(title: "Word can't be same as root word", message: "You can't use the same word as the root word")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        score += newWord.count
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                return
            }
            fatalError("Could not load start.txt from bundle.")
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        word.count > 3 ? true : false
    }
    
    func isNotSameAsRoot(word: String) -> Bool {
        word.lowercased() != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
