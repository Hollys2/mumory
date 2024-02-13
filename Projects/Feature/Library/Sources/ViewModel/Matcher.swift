




import Foundation
import ShazamKit
import AVFAudio

struct MatchResult: Equatable {
    let mediaItem: SHMatchedMediaItem?
    let question: Question?
    
    static func == (lhs: MatchResult, rhs: MatchResult) -> Bool {
        return lhs.question == rhs.question
    }
}

class Matcher: NSObject, ObservableObject, SHSessionDelegate {
    @Published var result = MatchResult(mediaItem: nil, question: nil)
    
    private var session: SHSession?
    private let audioEngine = AVAudioEngine()
    
    func match(catalog: SHCustomCatalog) throws {
        
        session = SHSession(catalog: catalog)
        session?.delegate = self
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: audioEngine.inputNode.outputFormat(forBus: 0).sampleRate,
                                        channels: 1)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 2048, format: audioFormat) { [weak session] buffer, audioTime in
            session?.matchStreamingBuffer(buffer, at: audioTime)
        }
        
        try AVAudioSession.sharedInstance().setCategory(.record)
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] success in
            guard success, let self = self else { return }
            try? self.audioEngine.start()
        }
    }
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {
            let newQuestion = Question.allQuestions.last { question in
                (match.mediaItems.first?.predictedCurrentMatchOffset ?? 0) > question.offset
            }
            
            if let currentQuestion = self.result.question, currentQuestion == newQuestion {
                return
            }
            
            self.result = MatchResult(mediaItem: match.mediaItems.first, question: newQuestion)
        }
    }
}


struct Question: Comparable, Equatable {
    let title: String
    let offset: TimeInterval
    let equation: Equation?
    let answerRange: ClosedRange<Int>
    let requiresAnswer: Bool
    
    init(title: String, offset: TimeInterval, equation: Equation? = nil, answerRange: ClosedRange<Int> = 0...0, requiresAnswer: Bool = false) {
        self.title = title
        self.offset = offset
        self.equation = equation
        self.answerRange = answerRange
        self.requiresAnswer = requiresAnswer
    }
    
    static func < (lhs: Question, rhs: Question) -> Bool {
        return lhs.offset < rhs.offset
    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.title == rhs.title && lhs.offset == rhs.offset
    }
}
