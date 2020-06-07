//
//  OZAudioPlayer.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/06.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import AVFoundation

public enum OZAudioPlayerStatus {
    case stopped, playing, paused
}

open class OZAudioPlayer {
    fileprivate var avPlayer: AVAudioPlayer!
    
    var status: OZAudioPlayerStatus = .stopped
    
    deinit {
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(false)
        }catch{
            
        }
    }
    
    func stop(){
        self.avPlayer?.stop()
        status = .stopped
    }
    
    func pause() {
        self.avPlayer?.pause()
        status = .paused
    }

    func resume() {
        self.avPlayer?.play()
        status = .playing
    }

    func play(named: String, complete: ((_ elapsed: TimeInterval, _ duration: TimeInterval) -> Void)?) {
        play(named: named)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (aTimer) in
            if let comp = complete, let avp = self.avPlayer {
                comp(avp.currentTime, avp.duration)
            }
            if self.status != .paused, let avp = self.avPlayer,
                !avp.isPlaying {
                self.status = .stopped
                aTimer.invalidate()
                
                if let comp = complete {
                    comp(self.avPlayer.duration, self.avPlayer.duration)
                }
            }
        }
    }
    
    func play(named: String) {
        guard let fileURL = OZAudioPlayer.getUrlFromPath(path: named) else { return }
        if self.avPlayer != nil{
            self.avPlayer?.stop()
            self.avPlayer = nil
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        
        guard let aPlayer = OZAudioPlayer.getAudioPlayer(fileURL: fileURL) else {
            stop()
            return
        }
        self.avPlayer = aPlayer
        self.avPlayer.numberOfLoops = 0
        self.avPlayer.prepareToPlay()
        self.avPlayer.play()
        status = .playing
        
        let volume = AVAudioSession.sharedInstance().outputVolume
        if volume == 0 {
            let message = "Volume up then you could hear audio.".localized
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            viewController?.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - Make AVPlayer
    public static func getAudioPlayer(fileURL: URL) -> AVAudioPlayer? {
        var aPlayer: AVAudioPlayer!
        do {
            if let wavData = OZAudioPlayer.getWaveDataFromAMR(fileURL: fileURL) {
                aPlayer = try AVAudioPlayer(data:wavData , fileTypeHint: AVFileType.wav.rawValue)
            }
            else {
                aPlayer = try AVAudioPlayer(contentsOf: fileURL)
            }
        }catch{}
        return aPlayer
    }
    public static func getAudioPlayer(data: Data) -> AVAudioPlayer? {
        var aPlayer: AVAudioPlayer!
        let mimeType = OZSwime.mimeType(data: data)
        do {
            if let aMime = mimeType, aMime.type == .amr {
                let wavData = OZAudioPlayer.decodeAmr2Wav(amrData: data)
                aPlayer = try AVAudioPlayer(data:wavData , fileTypeHint: AVFileType.wav.rawValue)
            }
            else {
                aPlayer = try AVAudioPlayer(data: data)
            }
        } catch {}
        return aPlayer
    }

    // MARK: - Check file path
    public static func getUrlFromPath(path: String) -> URL? {
        let fileName = path.fileName()
        let fileExt  = path.fileExtension()
        var filePath: String = path

        if let aFilePath = Bundle.path(forResource: fileName, ofType: fileExt.count > 0 ? fileExt : "mp3", inDirectory: Bundle.main.bundlePath) {
            filePath = aFilePath
        }
        else if let aFilePath = Bundle.path(forResource: fileName, ofType: fileExt.count > 0 ? fileExt : "wav", inDirectory: Bundle.main.bundlePath) {
            filePath = aFilePath
        }
        else if path.lowercased().hasPrefix("file"),
            let anUrl = URL(string: path) {
            filePath = anUrl.relativePath
        }
        else if path.hasPrefix("/") {
            filePath = path
        }
        return URL(fileURLWithPath: filePath)
    }
    
    
    // MARK: - Adaptive Multi-Rate Codec (GSM telephony)
    public static func isAMRFile(fileURL: URL) -> Bool {
        var mimeType: OZMimeType!
        var amrData: Data!
        do {
            amrData = try Data(contentsOf: fileURL)
            mimeType = OZSwime.mimeType(data: amrData)
        } catch {
            #if DEBUG
            print("OZVoiceVC:isAMRFile(fileURL:)::::cannot parse mime-type of \(fileURL.relativePath)")
            #endif
        }
        guard let aMime = mimeType, aMime.type == .amr else { return false }
        return true
    }
    public static func getWaveDataFromAMR(fileURL: URL) -> Data? {
        var mimeType: OZMimeType!
        var amrData: Data!
        do {
            amrData = try Data(contentsOf: fileURL)
            mimeType = OZSwime.mimeType(data: amrData)
        } catch {
            #if DEBUG
            print("OZVoiceVC:getWaveDataFromAMR(fileURL:)::::cannot parse mime-type of \(fileURL.relativePath)")
            #endif
        }
        guard let aMime = mimeType, aMime.type == .amr, let aData = amrData else { return nil }
        
        return OZAudioPlayer.decodeAmr2Wav(amrData: aData)
    }
    public static func getAmrDuration(fileURL: URL) -> TimeInterval {
        var mimeType: OZMimeType!
        var amrData: Data!
        do {
            amrData = try Data(contentsOf: fileURL)
            mimeType = OZSwime.mimeType(data: amrData)
        } catch {
            #if DEBUG
            print("OZVoiceVC:getAmrDuration(fileURL:)::::cannot parse mime-type of \(fileURL.relativePath)")
            #endif
        }
        guard let aMime = mimeType, aMime.type == .amr, let aData = amrData else { return 0 }
        guard let aPlayer = OZAudioPlayer.getAudioPlayer(data: aData) else { return 0 }
        
        return aPlayer.duration
    }
    public static func getAmrDuration(data: Data) -> TimeInterval {
        let mimeType = OZSwime.mimeType(data: data)
        guard let aMime = mimeType, aMime.type == .amr else { return 0 }
        guard let aPlayer = OZAudioPlayer.getAudioPlayer(data: data) else { return 0 }
        return aPlayer.duration
    }
    
    public static func decodeAmr2Wav(amrData data: Data) -> Data {
        return DecodeAMRToWAVE(data)
    }
    //let amrData = OZAudioPlayer.encodeWav2Amr(waveData: data, channels: 1, bitsPerSample: 16)
    public static func encodeWav2Amr(waveData data: Data, channels: Int, bitsPerSample: Int) -> Data {
        return EncodeWAVEToAMR(data, Int32(channels), Int32(bitsPerSample))
    }
}


public protocol OZAudioRecorderDelegate: class {
    func audioRecorderDidStartRecording(_ audioRecorder: OZAudioRecorder)
    func audioRecorderDidCancelRecording(_ audioRecorder: OZAudioRecorder)
    func audioRecorderDidStopRecording(_ audioRecorder: OZAudioRecorder, withURL url: URL?)
    /**
     Called when an audio recorder encounters an encoding error during recording.

     - parameter audioRecorder: The OZAudioRecorder that encountered the encoding error.
     - parameter error:         Returns, by-reference, a description of the error, if an error occurs.
     */
    func audioRecorderEncodeErrorDidOccur(_ audioRecorder: OZAudioRecorder, error: Error?)
    /**
     Called by the system when a recording is stopped or has finished due to reaching its time limit.

     This method is not called by the system if the audio recorder stopped due to an interruption.

     - parameter audioRecorder: The OZAudioRecorder that has finished recording.
     - parameter flag:          true on successful completion of recording; false if recording stopped because of an audio encoding error.
     */
    func audioRecorderDidFinishRecording(_ audioRecorder: OZAudioRecorder, successfully flag: Bool)

    func audioRecorderDidStartPlaying(_ audioRecorder: OZAudioRecorder)
    func audioRecorderDidStopPlaying(_ audioRecorder: OZAudioRecorder)
    /**
     Called when an audio player encounters a decoding error during playback.

     - parameter audioRecorder: The OZAudioRecorder that encountered the decoding error.
     - parameter error:         The decoding error.
     */
    func audioRecorderDecodeErrorDidOccur(_ audioRecorder: OZAudioRecorder, error: Error?)
    /**
     Called when a sound has finished playing.

     This method is not called upon an audio interruption. Rather, an audio player is paused upon interruption—the sound has not finished playing.

     - parameter audioRecorder: The OZAudioRecorder that finished playing.
     - parameter flag:          true on successful completion of playback; false if playback stopped because the system could not decode the audio data.
     */
    func audioRecorderDidFinishPlaying(_ audioRecorder: OZAudioRecorder, successfully flag: Bool)
}


open class OZAudioRecorder: NSObject {
    public static let shared = OZAudioRecorder()
    open weak var delegate: OZAudioRecorderDelegate?

    open fileprivate(set) var recorder: AVAudioRecorder? {
        willSet {
            if let newValue = newValue {
                newValue.delegate = self
            } else {
                recorder?.delegate = nil
            }
        }
    }
    open fileprivate(set) var player: AVAudioPlayer? {
        willSet {
            if let newValue = newValue {
                newValue.delegate = self
            } else {
                player?.delegate = nil
            }
        }
    }
    open var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    open var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    open var volume: Float = 1
    open var isProximityMonitoringEnabled = true
    open var isScreenBrightWhenPlaying = true

    // MARK: - Life cycle
    public override init () {
        super.init()
        commonInit()
    }

    deinit {
        recorder?.stop()
        recorder = nil
        player?.stop()
        player = nil
    }
    
    public func reset() {
        recorder?.stop()
        recorder = nil
        player?.stop()
        player = nil
    }
}

extension OZAudioRecorder {
    // MARK: - Record
    public func startRecord() {
        UIApplication.shared.isIdleTimerDisabled = true
        DispatchQueue.global().async {
            DispatchQueue.main.async { [weak self] in
                self?.recorder?.record()
            }
        }

        delegate?.audioRecorderDidStartRecording(self)
    }

    public func cancelRecord() {
        if !isRecording {
            return
        }

        DispatchQueue.global().async {
            DispatchQueue.main.async { [weak self] in
                self?.recorder?.stop()
                self?.recorder?.deleteRecording()
            }
        }
        UIApplication.shared.isIdleTimerDisabled = false

        delegate?.audioRecorderDidCancelRecording(self)
    }

    public func stopRecord() {
        let url = recorder?.url
        recorder?.stop()
        UIApplication.shared.isIdleTimerDisabled = false

        delegate?.audioRecorderDidStopRecording(self, withURL: url)
    }
}

extension OZAudioRecorder {
    // MARK: - Play
    /**
    Plays a WAVE audio asynchronously.

    If is playing, stop play, else start play.

    - parameter data: WAVE audio data
    */
    public func play(_ data: Data) {
        if player == nil {
            // is not playing, start play
            player = initPlayer(data)

            addProximitySensorObserver()
            if isScreenBrightWhenPlaying {
                UIApplication.shared.isIdleTimerDisabled = true
            }

            guard let success = player?.play() else {
                return
            }

            if success {
                delegate?.audioRecorderDidStartPlaying(self)
            } else {
                stopPlay()
            }
        } else {
            // is playing, stop play
            stopPlay()
        }
    }

    /**
     Plays an AMR audio asynchronously.

     If is playing, stop play, else start play.

     - parameter data: AMR audio data
     */
    public func playAmr(_ amrData: Data) {
        let decodedData = OZAudioPlayer.decodeAmr2Wav(amrData: amrData)
        play(decodedData)
    }

    public func stopPlay() {
        player?.stop()
        player = nil
        removeProximitySensorObserver()
        UIApplication.shared.isIdleTimerDisabled = false
        activateOtherInterruptedAudioSessions()

        delegate?.audioRecorderDidStopPlaying(self)
    }

    /**
     Get the duration of a WAVE audio data.

     - parameter data: WAVE audio data

     - returns: an optional NSTimeInterval instance.
     */
    public class func audioDuration(from data: Data) -> TimeInterval? {
        do {
            let player = try AVAudioPlayer(data: data)
            return player.duration
        } catch {

        }
        return nil
    }

    /**
     Get the duration of an AMR audio data.

     - parameter data: AMR audio data

     - returns: an optional NSTimeInterval instance.
     */
    public class func amrAudioDuration(from amrData: Data) -> TimeInterval? {
        let decodedData = OZAudioPlayer.decodeAmr2Wav(amrData: amrData)
        return audioDuration(from: decodedData)
    }
}

internal struct OZAudioRecorderConstants {
    internal static let recordSettings: [String: Any] = [AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                                                         AVSampleRateKey: NSNumber(value: 8000.0),
                                                         AVNumberOfChannelsKey: NSNumber(value: 1),
                                                         AVLinearPCMBitDepthKey: NSNumber(value: 16),
                                                         AVLinearPCMIsNonInterleaved: false,
                                                         AVLinearPCMIsFloatKey: false,
                                                         AVLinearPCMIsBigEndianKey: false]

    internal static func recordLocationURL() -> URL {
        let recordLocationPath = NSTemporaryDirectory().appendingFormat("%.0f.%@", Date.timeIntervalSinceReferenceDate * 1000, "caf")
        return URL(fileURLWithPath: recordLocationPath)
    }
}

extension OZAudioRecorder {
    // MARK: - Helpers
    fileprivate func commonInit() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        } catch let error {
            print("audio session set category error: \(error)")
        }
        activateOtherInterruptedAudioSessions()
        recorder = initRecorder()
    }

    fileprivate func updateAudioSessionCategory(_ category: AVAudioSession.Category, with options: AVAudioSession.CategoryOptions) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category, mode: .default, options: options)
        } catch let error {
            print("audio session set category error: \(error)")
        }
    }

    fileprivate func activateOtherInterruptedAudioSessions() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error {
            print("audio session set active error: \(error)")
        }
    }

    fileprivate func initRecorder() -> AVAudioRecorder? {
        var recorder: AVAudioRecorder?
        do {
            try recorder = AVAudioRecorder(url: OZAudioRecorderConstants.recordLocationURL(), settings: OZAudioRecorderConstants.recordSettings)
            recorder?.isMeteringEnabled = true
        } catch let error {
            print("init recorder error: \(error)")
        }
        return recorder
    }

    fileprivate func initPlayer(_ data: Data) -> AVAudioPlayer? {
        var player: AVAudioPlayer?
        do {
            try player = AVAudioPlayer(data: data)
            player?.volume = volume
            player?.prepareToPlay()
        } catch let error {
            print("init player error: \(error)")
        }
        return player
    }
}

extension OZAudioRecorder {
    // MARK: - Device Observer
    fileprivate func addProximitySensorObserver() {
        UIDevice.current.isProximityMonitoringEnabled = isProximityMonitoringEnabled
        if UIDevice.current.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(deviceProximityStateDidChange(_:)), name: UIDevice.proximityStateDidChangeNotification, object: nil)
        }
    }

    fileprivate func removeProximitySensorObserver() {
        if UIDevice.current.isProximityMonitoringEnabled {
            NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
        }
        UIDevice.current.isProximityMonitoringEnabled = false
    }

    @objc func deviceProximityStateDidChange(_ notification: Notification) {
        if UIDevice.current.proximityState {
            // Device is close to user
            updateAudioSessionCategory(.playAndRecord, with: [])
        } else {
            // Device is not close to user
            updateAudioSessionCategory(.playAndRecord, with: .defaultToSpeaker)
        }
    }
}

extension OZAudioRecorder: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    // MARK: - AVAudioRecorderDelegate and AVAudioPlayerDelegate
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                let url = weakSelf.recorder?.url
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderDidStopRecording(weakSelf, withURL: url)
                weakSelf.delegate?.audioRecorderDidFinishRecording(weakSelf, successfully: flag)
            }
        }
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.recorder?.stop()
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderEncodeErrorDidOccur(weakSelf, error: error)
            }
        }
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.player = nil
                weakSelf.removeProximitySensorObserver()
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderDidStopPlaying(weakSelf)
                weakSelf.delegate?.audioRecorderDidFinishPlaying(weakSelf, successfully: flag)
            }
        }
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                weakSelf.player?.stop()
                weakSelf.player = nil
                weakSelf.removeProximitySensorObserver()
                UIApplication.shared.isIdleTimerDisabled = false
                weakSelf.activateOtherInterruptedAudioSessions()

                weakSelf.delegate?.audioRecorderDecodeErrorDidOccur(weakSelf, error: error)
            }
        }
    }
}
