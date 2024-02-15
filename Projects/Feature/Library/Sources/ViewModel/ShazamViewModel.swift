/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model that is responsible for matching against the catalog and update the SwiftUI Views.
*/

import ShazamKit
import AVFAudio
import Combine
import MusicKit
import SwiftUI


struct ShazamMedia: Decodable {
    let title: String?
    let subtitle: String?
    let artistName: String?
    let albumArtURL: URL?
    let genres: [String]
}

class ShazamViewModel: NSObject, ObservableObject {
    @Published var shazamSong: SHMatchedMediaItem?
    @Published var isRecording = false
    @Published var isShazamCompleted: Bool = false
    
    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
    private let signatureGenerator = SHSignatureGenerator()

    override init() {
        super.init()
        session.delegate = self
    }

    public func startOrEndListening() {
        //실행중이라면 멈추고 return
        guard !audioEngine.isRunning else {
            audioEngine.stop()
            DispatchQueue.main.async {
                withAnimation {
                    self.isRecording = false
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.isRecording = true
                self.isShazamCompleted = false
            }
        }
        
        let audioSession = AVAudioSession.sharedInstance()

        audioSession.requestRecordPermission { granted in
            guard granted else { return }
            try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = self.audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0,
                                 bufferSize: 1024,
                                 format: recordingFormat) { (buffer: AVAudioPCMBuffer,
                                                             when: AVAudioTime) in
                self.session.matchStreamingBuffer(buffer, at: nil)
            }

            self.audioEngine.prepare()
            do {
                try self.audioEngine.start()
            } catch (let error) {
                DispatchQueue.main.async {
                    self.isRecording = false
                }
                assertionFailure(error.localizedDescription)
            }

        }
    }
}

extension ShazamViewModel: SHSessionDelegate {
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            withAnimation {
                self.isRecording = false
                self.isShazamCompleted = false
            }
        }
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)


    }

    func session(_ session: SHSession, didFind match: SHMatch) {
        let mediaItems = match.mediaItems

        if let firstItem = mediaItems.first {
            
//            guard let resultSong = firstItem.songs.first else {
//                return
//            }
//            print("art work url: \(resultSong.artwork?.url(width: 500, height: 500)?.absoluteString)")
            DispatchQueue.main.async {
                withAnimation {
                    self.shazamSong = firstItem
                    self.isShazamCompleted = true
                    self.isRecording = false
                }

            }
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)


        }
    }
}
