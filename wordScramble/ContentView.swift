//
//  ContentView.swift
//  wordScramble
//
//  Created by saj panchal on 2021-06-07.
//

import SwiftUI

struct ContentView: View {
    @State var usedWords = [String]()
    @State var rootWord = ""
    @State var newWord = ""
    @State var errorTitle = ""
    @State var errorMessage = ""
    @State var showingError = false
    @State var score = 0
    @State var count: Int = 0
    var counts: Int {
        get {
           return count
        }
        set {
           return count = newValue
        }
    }
        var body: some View {
            NavigationView {
                GeometryReader { geo in
                    VStack {
                        TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .autocapitalization(.none)
                        List(usedWords, id:\.self) { word in
                            
                            //if we show list items dynamically, all contents in list will appear horizontally in one row.
                           GeometryReader { txt in
                                HStack {
                                    Image(systemName: "\(word.count).circle").foregroundColor((Color(red: (usedWords.firstIndex(of: word)! % 2 == 0) ?  Double((txt.frame(in:.global).minY) / txt.frame(in:.global).maxY) : 0.0, green: (usedWords.firstIndex(of: word)! % 2 != 0) ?  Double((txt.frame(in:.global).minY) / txt.frame(in:.global).maxY) : 0.0, blue: (usedWords.firstIndex(of: word)! % 3 == 0) ?  Double((txt.frame(in:.global).minY) / txt.frame(in:.global).maxY) : 0.0)))
                                    Text(word + "\(Double((txt.frame(in:.global).minY) / txt.frame(in:.global).maxY))")
                                        .offset(x: (usedWords.firstIndex(of: word)! > 8) ? txt.frame(in: .global).minY * 0.3 : 0.0)
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibility(label: Text("\(word), \(word.count) letters"))
                            }
                        }
                        Text("Score is: \(score)")
                    }.navigationBarTitle(rootWord)
                    .navigationBarItems(trailing: Button("Play", action: startGame))
                    .onAppear(perform: startGame) // it will be called when view appears
                    .alert(isPresented: $showingError, content: {
                        Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    })
                }
               
        }
    }
    func addNewWord() {
        // convert string to lowercase and trim whitespaces and new lines.
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // if string is empty exit the function
        guard answer.count > 0 else {
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "word not recognized", message: "You can't just make them up, you know!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "word not possible", message: "That isn't a real word.")
            return
        }
        // add a given item to the used words list.
        score += 1
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    func startGame() {
        // get the url of a given file from bundle.
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // get the contents of a file in form of a string.
            if let startWords = try? String(contentsOf: startWordsURL) {
                // convert a string in an array of sub strings separated from end of line.
                let allWords = startWords.components(separatedBy: "\n")
                // from arrays select a random word and copy it to rootword.
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.") // a swift function that terminates a program with error message.
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord // the word that is displayed
        // check the user's word letters with the tempWord string index.
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            }
            else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        if word.count == 3 {
            return false
        }
        if word.count < rootWord.count {
            return false
        }
        let checker = UITextChecker() // text checker
        let range = NSRange(location: 0, length: word.utf16.count) // range of a user word in utf16 format
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en") // use range and word as an arg of this checker method to get the index of missplelled letters.
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
