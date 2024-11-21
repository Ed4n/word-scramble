import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var newWord: String = ""
    @State private var rootWord: String = ""
    
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    @State private var score: Int = 0
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar {
                
               ToolbarItem(placement: .navigationBarLeading) {
                   Text("Score: \(score)")
               }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Restart") {
                        startGame()
                    }
                }
            
            }
            .alert(errorTitle, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return }
        
        guard answer.count >= 3 else {
            wordError(title: "Word too short", message: "Word must be more thant 3 characters.")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Answer Cannot Be Same", message: "Answer cannot be same as root word.")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word Used Already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word Not Possible", message: "You can't spell that word from \(rootWord).")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word Not Recognized", message: "That isn't a real word.")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        score += 1
        newWord = ""
    }
    
    func startGame() {
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt"),
           let startWords = try? String(contentsOf: startWordUrl, encoding: .utf8) {
//            Here I'm separating the words in the file by the like break
            let allWords = startWords.components(separatedBy: "\n")
            rootWord = allWords.randomElement() ?? "Silkworm"
        } else {
            rootWord = "No Words"
            print("Couldn't load start words. Falling back to default.")
        }
        
        newWord = ""
        usedWords.removeAll()
        score = 0
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

    // All this method is a way to check if a word exist, it's like a default in swift and it use objective-c
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let matches = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return matches.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

#Preview {
    ContentView()
}
