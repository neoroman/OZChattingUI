//
//  OZVoiceRecordViewController.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

fileprivate let kButtonTintColor = UIColor(red: 229.0 / 255.0, green: 21.0 / 255.0, blue: 0.0, alpha: 1.0)

open class OZVoiceRecordViewController: UIViewController {

    var delegate: Any?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var voiceViewCloseButton: UIButton!
    @IBOutlet weak var voiceTimeLabel: UILabel!
    @IBOutlet weak var voiceRecordButton: UIButton!
    @IBOutlet weak var voiceSendButton: UIButton!
    @IBOutlet weak var voiceLevelView: NVActivityIndicatorView!
    var voiceProgressView: OZCircleProgressView? = nil

    // Adaptive Multi-Rate Codec (GSM telephony)
    public var isUsingAMRFormat = true
    private var amrAudioRecorder: OZAudioRecorder?
    private var voiceData: Data?
    
    // Buttons
    var vpBtnRecordStop         = UIImage(named: "voicemsBtnRecordStop")
    var vpBtnRecordStopPressed  = UIImage(named: "voicemsBtnRecordStopPress")
    var vpBtnRecordPlay         = UIImage(named: "voicemsBtnRecordPlay")
    var vpBtnRecordPlayPressed  = UIImage(named: "voicemsBtnRecordPlayPress")
    var vpBtnRecord             = UIImage(named: "voicemsBtnRecord")
    var vpBtnRecordPressed      = UIImage(named: "voicemsBtnRecordPress")
    
    // Recorder
    public var voiceFilePath: URL?
    public var tempFilePath: URL?
    public var recordMaxDuration: TimeInterval = 10
    fileprivate var recordElapsedTime: TimeInterval = 0
    fileprivate var recordedDuration: TimeInterval = 0
    fileprivate var audioRecorder: AVAudioRecorder?
    var isMicPermmison = false
    var isPermissionCheck = false
    var voiceState: RecordState = .normal {
        didSet {
            if isViewLoaded, oldValue != voiceState {
                self.actions(byState: oldValue)
                self.display(byState: voiceState)
            }
        }
    }
    enum RecordState {
        case playing/*재생상태*/, stop/*중지상태*/, recording/*녹음중상태*/, normal/*녹음대기상태*/
    }

    // Player
    fileprivate var playElapsedTime: TimeInterval = 0
    private var audioPlayer: OZAudioPlayer?

    var timer: Timer?
    var isSending = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Voice view related
        voiceTimeLabel.text = ""
        voiceSendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        voiceSendButton.setTitleColor(UIColor(white: 153.0 / 255.0, alpha: 1.0), for: .normal)
        voiceSendButton.layer.cornerRadius = voiceSendButton.frame.height / 2
        voiceSendButton.layer.masksToBounds = true
        voiceSendButton.layer.borderColor = UIColor.gray.cgColor
        voiceSendButton.layer.borderWidth = 1
        if let aCircleProgress = createCircleProgressView() {
            aCircleProgress.layer.cornerRadius = (voiceProgressView?.frame.height)! / 2
            aCircleProgress.layer.masksToBounds = true
        }
        voiceLevelView.type = .audioEqualizer
        voiceLevelView.color = UIColor(red: 251.0 / 255.0, green: 139.0 / 255.0, blue: 125.0 / 255.0, alpha: 1.0)
                
        self.display(byState: voiceState)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(routeChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    // MARK: - Orientations
    /* TODO: do something here by Henry on 2020.05.09
     override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
     super.viewWillTransition(to: size, with: coordinator)
     self.view.frame.origin = CGPoint.zero
     if UIDevice.current.orientation.isLandscape {
     print("Landscape")
     self.view.frame.size = CGSize(width: super.view.bounds.height / 2, height: super.view.bounds.width)
     } else {
     print("Portrait")
     self.view.frame.size = CGSize(width: super.view.bounds.width, height: super.view.bounds.height)
     }
     self.view.setNeedsLayout()
     }
     */
    
    // MARK: - Display by VoiceState
    fileprivate func display(byState: RecordState) {
        switch byState {
        case .playing, .recording:
            voiceRecordButton.setImage(vpBtnRecordStop, for: .normal)
            voiceRecordButton.setImage(vpBtnRecordStopPressed, for: .highlighted)
            
            var aTime = recordMaxDuration - recordElapsedTime
            if byState == .playing {
                aTime = 0
            }
            voiceTimeLabel.text = String(format: "%02d:%02d", Int(round(aTime)) / 60, Int(round(aTime)) % 60)
            voiceLevelView.startAnimating()
            voiceSendButton.isEnabled = false
        case .stop:
            resetViews()
            voiceRecordButton.setImage(vpBtnRecordPlay, for: .normal)
            voiceRecordButton.setImage(vpBtnRecordPlayPressed, for: .highlighted)
            if checkAudioFile(path: nil) {
                voiceSendButton.isEnabled = true
                if let vpv = voiceProgressView {
                    vpv.removeFromSuperview()
                    voiceProgressView = nil
                }
            }
        case .normal:
            voiceRecordButton.setImage(vpBtnRecord, for: .normal)
            voiceRecordButton.setImage(vpBtnRecordPressed, for: .highlighted)
            voiceTimeLabel.text = ""
            voiceSendButton.isEnabled = false
            if let vpv = voiceProgressView {
                vpv.removeFromSuperview()
                voiceProgressView = nil
            }
        }
    }
    
    // MARK: - Actions by VoiceState
    fileprivate func actions(byState: RecordState, isForceStop: Bool = false) {

        guard !isSending else { return }
        
        // Action by ``oldValue''
        switch byState {
        case .playing:
            finishPlaying(!isForceStop)
        case .recording:
            if let aar = amrAudioRecorder, aar.isRecording {
                aar.stopRecord()
            }
        case .stop:
            if checkAudioFile(path: nil) {
                self.startPlaying()
            }
        case .normal:
            self.startRecording()
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // MARK: - App life cycle
    @objc func appMovedToBackground(_ sender: Notification) {
        if voiceState == .recording {
            finishRecording(success: true)
        } else if voiceState == .playing {
            actions(byState: voiceState)
        }
    }
    
    
    
    // MARK: - Targets and Actions
    @IBAction func backgroundTouched(_ sender: Any) {
        print("OZVoiceVC:::::backgroundTouched...!")
        
    }
    @IBAction func micContainerCloseButtonPressed(_ sender: Any) {
        if let dele = delegate as? OZMessagesViewController {
            dele.chatState = .chat
        }
        if voiceState != .normal {
            voiceState = .normal
        }
        initialVoiceMessage()
    }
    @IBAction func voiceRecordButtonPressed(_ sender:Any) {
        print("OZVoiceVC:::::voiceRecordButtonPressed...!")
        
        switch voiceState {
        case .playing:
            voiceState = .stop
        case .recording:
            voiceState = .stop
        case .stop:
            voiceState = .playing
        case .normal:
            // 마이크 퍼머션 체크
            if isMicPermmison == false {
                checkPermissionMic()
                return
            }
            voiceState = .recording
        }
    }
    @IBAction func voiceSendButtonPressed(_ sender:Any) {
        print("OZVoiceVC:::::voiceSendButtonPressed...!")
        if !isSending {
            isSending = true
            //finishPlaying(true)
            
            if let dele = delegate as? OZMessagesViewController,
                let url = self.voiceFilePath {
                dele.send(msg: url.relativePath, type: .voice) { (id, content) in
                    dele.chatState = .chat
                }
            }
            micContainerCloseButtonPressed("" as Any)
        }
    }
    
    func createCircleProgressView(width: CGFloat = 2.0) -> OZCircleProgressView? {
        if voiceProgressView == nil {
            let inset = UIEdgeInsets.zero
            let rect = voiceRecordButton.frame.inset(by: inset)
            voiceProgressView = OZCircleProgressView(frame: rect)
            voiceProgressView?.color = .red
            voiceProgressView?.width = width
            containerView.addSubview(voiceProgressView!)
            containerView.bringSubviewToFront(voiceProgressView!)
            containerView.bringSubviewToFront(voiceRecordButton)
        }
        return voiceProgressView
    }
}


// MARK: - Audio Route Change
extension OZVoiceRecordViewController {
    @objc func routeChanged(_ noti: Notification) {
        print("OZ >>>> noti = \(noti)")
    }
}


// MARK: - Audio Handling
extension OZVoiceRecordViewController {
    //MARK: Initial Audio Recorder
    func initialVoiceMessage() {
        initialTimer()
        recordElapsedTime = 0
        recordedDuration = 0
        voiceFilePath = nil
        voiceData = nil
        audioPlayer = nil
        isSending = false
        resetViews()
    }
    
    func resetViews() {
        // UI Clearing
        voiceLevelView.stopAnimating()
        if let vpv = voiceProgressView {
            vpv.removeFromSuperview()
            voiceProgressView = nil
        }
        
        if let vPath = voiceFilePath, FileManager.isFileExist(named: vPath.relativePath) {
            voiceSendButton.layer.borderColor = UIColor.red.cgColor
            voiceSendButton.setTitleColor(.red, for: .normal)
            voiceSendButton.isEnabled = true
        }
        else {
            voiceSendButton.layer.borderColor = UIColor.gray.cgColor
            voiceSendButton.setTitleColor(.gray, for: .normal)
            voiceSendButton.isEnabled = false
        }
        
        var aMaxTime = recordMaxDuration
        if recordedDuration > 0 {
            aMaxTime = recordedDuration
        }
        voiceTimeLabel.text = String(format: "%02d:%02d",
                                     Int(round(aMaxTime)) / 60,
                                     Int(round(aMaxTime)) % 60)
    }
    
    func finishRecording(success: Bool) {
        
        initialTimer()
        
        if isUsingAMRFormat {
            guard let url = tempFilePath, let waveData = try? Data(contentsOf: url) else { return }
            let amrData = OZAudioPlayer.encodeWav2Amr(waveData: waveData, channels: 1, bitsPerSample: 16)
            voiceData = amrData
            if let vPath = voiceFilePath {
                saveAudioFile(data: amrData, path: vPath)
                if let duration = OZAudioRecorder.amrAudioDuration(from: amrData) {
                    recordedDuration = duration
                }
                if let vpv = voiceProgressView {
                    vpv.removeFromSuperview()
                    voiceProgressView = nil
                }

                if checkAudioFile(path: vPath),
                    let aar = amrAudioRecorder, !aar.isRecording {
                    aar.reset()
                }
            }
        }
        else {
            self.audioRecorder?.stop()
            if success {
                print("OZVoiceVC:::::finishRecording")
                guard let audioFilePath = self.voiceFilePath else { return }
                
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: audioFilePath.path)
                    let fileSize = attr[FileAttributeKey.size] as! UInt64
                    print("OZVoiceVC:::::filesize : \(fileSize)")
                } catch {
                    print("OZVoiceVC:::::No such audio file in \(audioFilePath.absoluteString)")
                }
                
                guard let waveData = try? Data(contentsOf: audioFilePath) else { return }
                let amrData = OZAudioPlayer.encodeWav2Amr(waveData: waveData, channels: 1, bitsPerSample: 16)
                voiceData = amrData
                if let vPath = voiceFilePath {
                    saveAudioFile(data: amrData, path: vPath)
                    
                    //guard let voiceData = voiceData else { return }
                    recordedDuration = OZAudioPlayer.getAmrDuration(data:amrData)
                    if let vpv = voiceProgressView {
                        vpv.removeFromSuperview()
                        voiceProgressView = nil
                    }
                }
                self.audioRecorder = nil
            } else {
                print("OZVoiceVC:::::force Stop")
            }
        }

        voiceState = .stop
    }
    
    func finishPlaying(_ success:Bool) {
        guard let ap = audioPlayer else { return }
        
        ap.stop()
        audioPlayer = nil
        initialTimer()
        resetViews()
        voiceState = .stop
    }
    
    func initialTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func progressFn(_ :Timer) {
        if self.voiceState == .recording {
            if recordElapsedTime < recordMaxDuration {
                recordElapsedTime += 1
                let aTime = recordMaxDuration - recordElapsedTime
                print("OZVoice::: maxDuration(\(recordMaxDuration)), elapsedTime(\(recordElapsedTime)), aTime(\(aTime))")
                if aTime >= 0 {
                    voiceTimeLabel.text = String(format: "%02d:%02d", Int(round(aTime)) / 60, Int(round(aTime)) % 60)
                }
            } else {
                recordElapsedTime = 0
                initialTimer()
                if let aar = amrAudioRecorder, aar.isRecording {
                    aar.stopRecord()
                }
            }
        }
    }
    
    fileprivate func startRecording() {
        // 마이크 퍼머션 체크
        if isMicPermmison == false {
            checkPermissionMic()
            return
        }
        
        initialVoiceMessage()
        
        if self.isUsingAMRFormat {
            amrAudioRecorder = OZAudioRecorder()
            if let aar = amrAudioRecorder {
                self.voiceFilePath = self.generateFilePath()
                aar.delegate = self
                aar.stopPlay()
                aar.startRecord()
                
                self.recordElapsedTime = 0
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.progressFn(_:)), userInfo: nil, repeats: true)
                if let vpv = createCircleProgressView() {
                    vpv.progress(from: 0.0, to: 1.0, duration: self.recordMaxDuration)
                }
            }
        }
        else {
            self.voiceFilePath = self.generateFilePath()
            guard let vPath = self.voiceFilePath else {
                print("OZVoiceVC:::::voiceFilePath is nil")
                return
            }
            
            // step1
            let audioRecordSettings = [//AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 11025,
                AVEncoderBitRateKey: 16,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue]
            try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            if let config = AVAudioFormat(settings: audioRecordSettings) {
                do {
                    self.audioRecorder = try AVAudioRecorder(url: vPath, format: config)
                    self.audioRecorder?.delegate = self
                    self.audioRecorder?.record()
                    
                    self.recordElapsedTime = 0
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.progressFn(_:)), userInfo: nil, repeats: true)
                    if let vpv = createCircleProgressView() {
                        vpv.progress(from: 0.0, to: 1.0, duration: self.recordMaxDuration)
                    }
                } catch {
                    print("OZVoiceVC:::::Cannot make AVAudioRecorder")
                    self.finishRecording(success: false)
                }
            }
            else {
                print("OZVoiceVC:::::AVAudioFormat config has something wrong")
                self.finishRecording(success: false)
            }
        }
    }
    fileprivate func startPlaying() {
        guard let audioFilePath = self.voiceFilePath else { return }
        if audioPlayer == nil {
            audioPlayer = OZAudioPlayer()
        }
        audioPlayer?.play(named: audioFilePath.relativePath, complete: { (elapse, duration) in
            let aTime = Int(round(elapse))
            self.voiceTimeLabel.text = String(format: "%02d:%02d", aTime / 60, aTime % 60)
            if elapse >= duration {
                self.audioPlayer?.stop()
                self.audioPlayer = nil
                self.voiceState = .stop
                self.initialTimer()
            }
        })
        if let vpv = createCircleProgressView() {
            let duration = self.recordedDuration > 0 ? self.recordedDuration : self.recordMaxDuration
            vpv.progress(from: 0.0, to: 1.0, duration: duration)
        }

    }
    
    // MARK: - Audio(Voice) File Related
    fileprivate func generateFilePath() -> URL {
        let audioFileName = String(format:"%@.amr", String.randomFileName(length: 10))
        let tempDirUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let vPath = tempDirUrl.appendingPathComponent(audioFileName)
        return vPath
    }
    fileprivate func audioFileName(path: URL) -> String {
        return path.relativePath.fileName() + "." + path.relativePath.fileExtension()
    }
    fileprivate func saveAudioFile(data: Data, path: URL) {
        do {
            try data.write(to: path)
            voiceSendButton.layer.borderColor = UIColor.red.cgColor
            voiceSendButton.setTitleColor(.red, for: .normal)
            voiceSendButton.isEnabled = true
        } catch {
            print("OZVoiceVC:::::Cannot save audio file in \(path.absoluteString)")
            return
        }
        _ = checkAudioFile(path: path)
    }
    fileprivate func checkAudioFile(caller: String = #function, path: URL?) -> Bool {
        var aPath = path
        if let vPath = voiceFilePath {
            aPath = vPath
        }
        if let finalUrl = aPath {
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: finalUrl.path)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                print("OZVoiceVC:::::filesize : \(fileSize)")
                return true
            } catch {
                print("OZVoiceVC:(from \(caller))::::No such audio file in \(finalUrl.path)")
            }
        }
        return false
    }
}


// MARK: - Audio & Mic usage permissions
extension OZVoiceRecordViewController {
    func checkPermissionMic() {
        if let parent = delegate as? OZMessagesViewController,
            let dele = parent.delegate {
            dele.messageMicWillRequestRecordPermission(viewController: self)
        }
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            self.setMic(permissionCheck: true, firstCheck: false)
        case AVAudioSession.RecordPermission.denied:
            self.setMic(permissionCheck: false, firstCheck: false)
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    self.setMic(permissionCheck: true, firstCheck: true)
                } else {
                    self.setMic(permissionCheck: false, firstCheck: true)
                }
            })
        default:
            break
        }
    }
    
    func setMic(permissionCheck: Bool, firstCheck: Bool) {
        OperationQueue.main.addOperation() {
            self.isMicPermmison = permissionCheck
            print("OZVoiceVC:::::isPermissionCheck = \(self.isPermissionCheck), \(permissionCheck), \(firstCheck)")
            if permissionCheck == false && firstCheck == false {
                if self.isPermissionCheck {
                    self.alertForGotoSettings()
                }
                else {
                    self.alertForGotoSettings()
                    return
                }
            }
            else {
                if self.isMicPermmison {
                    self.startRecording()
                    self.voiceState = .recording
                }
            }
            self.isPermissionCheck = false
        }
    }
    
    fileprivate func alertForGotoSettings() {
        let alert = UIAlertController(title: NSLocalizedString("Need to access grand for MIC.", comment: ""), message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            if let systemSettingsUrl = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(systemSettingsUrl) {
                UIApplication.shared.open(systemSettingsUrl) { (success) in
                    // code
                }
            }
        })
        let cancel = UIAlertAction(title: NSLocalizedString("Deny", comment: "Deny"), style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - AVAudioRecorderDelegate
extension OZVoiceRecordViewController: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording(success: true)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlaying(true)
    }
}


// MARK: - AMRAudioRecorderDelegate
extension OZVoiceRecordViewController: OZAudioRecorderDelegate {
    // Recording
    public func audioRecorderDidStartRecording(_ audioRecorder: OZAudioRecorder) {
        print("OZVoiceVC************start recording*********************")
        //        state = .recording
    }
    public func audioRecorderDidCancelRecording(_ audioRecorder: OZAudioRecorder) {
        print("OZVoiceVC************cancel recording*********************")
        //        state = .normal
    }
    public func audioRecorderDidStopRecording(_ audioRecorder: OZAudioRecorder, withURL url: URL?) {
        print("OZVoiceVC*************Stop recording \(String(describing: url?.relativePath))*********************")
        guard let url = url else { return }
        tempFilePath = url
        finishRecording(success: true)
    }
    public func audioRecorderDidFinishRecording(_ audioRecorder: OZAudioRecorder, successfully flag: Bool) {
        let result = flag ? "successfully" : "unsuccessfully"
        print("OZVoiceVC*************finish recording \(result)*********************")
    }
    // Playing
    public func audioRecorderDidStartPlaying(_ audioRecorder: OZAudioRecorder) {
        print("OZVoiceVC************start playing*********************")
    }
    public func audioRecorderDidStopPlaying(_ audioRecorder: OZAudioRecorder) {
        print("OZVoiceVC************stop playing*********************")
        //resetViews()
    }
    public func audioRecorderDidFinishPlaying(_ audioRecorder: OZAudioRecorder, successfully flag: Bool) {
        let result = flag ? "successfully" : "unsuccessfully"
        print("OZVoiceVC*************finish playing \(result)*********************")
        finishPlaying(true)
    }
    public func audioRecorderEncodeErrorDidOccur(_ audioRecorder: OZAudioRecorder, error: Error?) {
        //code
    }
    public func audioRecorderDecodeErrorDidOccur(_ audioRecorder: OZAudioRecorder, error: Error?) {
        //code
    }
}
