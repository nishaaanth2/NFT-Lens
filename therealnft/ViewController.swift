import AVFoundation
import UIKit
import Lottie
import CocoaMQTT
import SwiftMQTT
import CocoaAsyncSocket
import Photos

class ViewController: UIViewController {
   
    
    var mqtt: CocoaMQTT?
    let animationView = AnimationView()
    var holdFlag = false
    var holdVal = 0
    //captureSession
    var oldyet : String?
    let shapeLayer = CAShapeLayer()

    var session: AVCaptureSession?
    //photoOutput
    let output = AVCapturePhotoOutput()
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var activeInput: AVCaptureDeviceInput!
    let movieOutput = AVCaptureMovieFileOutput()

    var data: Data?
    //VideoPreview
    //ShutterButton
    
//    let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTakeGIF))

    var timer: Timer?
    var speedAmmo = 20

    var tempURL: URL? {
      let directory = NSTemporaryDirectory() as NSString
      if directory != "" {
        let path = directory.appendingPathComponent("video.mov")
        return URL(fileURLWithPath: path)
      }
      return nil
    }
    
    var comp : ((String) -> Void)?
    
    private let shutterButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.backgroundColor = UIColor.white.cgColor
        button.isUserInteractionEnabled = true
        button.isEnabled = true

        //        button.layer.backgroundColor = UIColor.blue.cgColor
        //        button.setImage(UIImage(systemName: "redxx"), for: .normal)
        //        let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
        //        let boldSearch = UIImage(systemName: "search", withConfiguration: boldConfig)
        
        //        button.setImage(boldSearch, for: .normal)
        return button
    }()
    
    private let textview : UITextView = {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        textView.text = "Tap to search"
        textView.font = UIFont(name: "Montserrat-Light", size: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        
        textView.toggleBoldface(false)
        

        return textView
    }()
    private let textvieww : UITextView = {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        textView.text = "Long press to record"
        textView.font = UIFont(name: "Montserrat-Light", size: 12)
        textView.textColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.toggleBoldface(false)

        return textView
    }()
    
    private let titledaw : UITextView = {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        textView.text = "NFT Lens"
        textView.font = UIFont(name: "Bitsumishi", size:28 )
        textView.textColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.toggleBoldface(false)

        return textView
    }()
    
    private let square : UIImageView = {
        let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 300 , height: 300))
        img.image = UIImage(named: "square")

        return img
    }()
    
    func VsetupSession() {
        session?.beginConfiguration()
      guard let camera = AVCaptureDevice.default(for: .video) else {
        return
      }
      guard let mic = AVCaptureDevice.default(for: .audio) else {
        return
      }
      do {
        let videoInput = try AVCaptureDeviceInput(device: camera)
        let audioInput = try AVCaptureDeviceInput(device: mic)
        for input in [videoInput, audioInput] {
            if session!.canAddInput(input) {
                session!.addInput(input)
          }
        }
        activeInput = videoInput
      } catch {
        print("Error setting device input: \(error)")
        return
      }
        session!.addOutput(movieOutput)
        session!.commitConfiguration()
    }

    func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
      let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
      let devices = discovery.devices.filter {
        $0.position == position
      }
      return devices.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clientID = "CocoaMQTT-Welcome" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "hairdresser.cloudmqtt.com", port: 15488)
        mqtt?.username = "pcxwoore"
        mqtt?.password = "hhZmNsQrWfBW"
        mqtt?.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt?.keepAlive = 60
        mqtt?.delegate = self
        

//        mqtt.allowUntrustCACertificate = true
        view.backgroundColor = .black
//        print(UIDevice.current.identifierForVendor!.uuidString)
        
        
        
        //_______________________________ON__________________---><><><<><<<
//        shutterButton.addTarget(self, action: #selector(didTakePhoto), for: .touchUpInside)
//        shutterButton.addTarget(self, action: #selector(didTakeGIF), for: .touchUpInside)
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
//            self.view.addGestureRecognizer(tapGestureRecognizer)
////
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
//            self.shutterButton.addGestureRecognizer(longPressRecognizer)
        
        shutterButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        shutterButton.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
      
        
        
//        shutterButton.addGestureRecognizer(self.cameraButtonRecognizer)

//        self.view.addSubview(shutterButton)
        checkCameraPermission()
        setupAnimation()
        
        

    }
    
    
    public func captureMovie() {
      guard let connection = movieOutput.connection(with: .video) else {
        return
      }
      if connection.isVideoStabilizationSupported {
        connection.preferredVideoStabilizationMode = .auto
      }
      let device = activeInput.device
      if device.isSmoothAutoFocusEnabled {
        do {
          try device.lockForConfiguration()
          device.isSmoothAutoFocusEnabled = true
          device.unlockForConfiguration()
        } catch {
          print("error: \(error)")
        }
      }
      guard let outUrl = tempURL else { return }
      movieOutput.startRecording(to: outUrl, recordingDelegate: self)
    }

    public func stopRecording() {
      if movieOutput.isRecording {
        movieOutput.stopRecording()
      }
    }
    
    @objc func buttonDown(_ sender: UIButton) {
//        print("down")
        
            singleFire()
            timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rapidFire), userInfo: nil, repeats: true)
        }

        @objc func buttonUp(_ sender: UIButton) {
//            print("up")
            if(holdVal>2){
                stopRecording()
                print("stop recording ok")
            }
            else{
                print("tap")
                didTakePhoto()
            }

            timer?.invalidate()
            holdVal=0

        }

        func singleFire() {
            print(holdVal)
            if(holdVal == 2){
                print("start recording dummydaw")
//                startCapture()
            }
        }
    @objc func rapidFire() {
        if speedAmmo > 0 {
//            speedAmmo -= 1
            holdVal += 1
//            print("bang!")
        } else {
            print("out of speed ammo, dude!")
            timer?.invalidate()
        }
        print(holdVal)
        if(holdVal == 2){
            print("start recording ok")
            captureMovie()
            
        }
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        session?.stopRunning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        if !session!.isRunning {
//          DispatchQueue.global(qos: .default).async { [weak self] in
        self.session?.startRunning()
//          }
//        }
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = view.bounds
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 110)
        textview.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 15)
        textvieww.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height )
        titledaw.center = CGPoint(x: view.frame.size.width/2, y: 100)
        square.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)

    }
    
    private func checkCameraPermission(){
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
        
        case .notDetermined:
            //request
            AVCaptureDevice.requestAccess(for: .video) { [weak self]
                granted in
                guard granted else{
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
        
        
        VsetupSession()
    }
    
    private func setUpCamera(){
        
        let session = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video) {
            do{
                let input = try AVCaptureDeviceInput(device: device)
                
                if(session.canAddInput(input)){
                    session.addInput(input)
                }
                if(session.canAddOutput(output)){
                    session.addOutput(output)
                }
                // here is everythingzzzzazazazazazazaza
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
//                if !session.isRunning {
//                  DispatchQueue.global(qos: .default).async { [weak self] in
                    session.startRunning()
//                  }
//                }

                self.session = session
            }
            catch{
                print(error)
            }
        }
        
    }
    
    @objc private func didTakePhoto(){
        
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
    }
    @objc private func didTakeGIF(){
        
        print("hehehehe")
        
    }
    private func setupAnimation(){
        
        animationView.animation = Animation.named("nft_anim")
        animationView.frame = CGRect(x: 0, y: 0, width: 450, height: 450)
        animationView.center = view.center
        animationView.backgroundColor = .black
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        
        animationView.play { value in
            
            self.setLayers()
        }
        self.view.addSubview(animationView)
        
    }
    func tapped(sender: UITapGestureRecognizer)
    {
        print("tapped")
    }

    func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
    }
    private func setLayers(){
        
        self.animationView.stop()
        _ = mqtt?.connect()
        

        self.previewLayer.addSublayer(self.textview.layer)
        self.previewLayer.addSublayer(self.textvieww.layer)
        self.previewLayer.addSublayer(self.titledaw.layer)
        self.previewLayer.addSublayer(self.square.layer)
        self.view.layer.addSublayer(self.previewLayer)
        self.view.addSubview(shutterButton)

        
    }
    
    
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }

    //EDIT 1: I FORGOT THIS AT FIRST


    
}


extension ViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        data = photo.fileDataRepresentation()  // capture data stores in "data"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LuckViewController") as? LuckViewController
        vc?.imagedata = data
        vc?.luckmqtt = mqtt
        
        oldyet = UIDevice.current.identifierForVendor!.uuidString + String(100000 + arc4random_uniform(900000))
        vc?.yet = oldyet?.lowercased()
        vc?.resultanswer = "should send"
        vc?.resultComp = self.comp
        //       vc?.modalPresentationStyle = .fullScreen
        vc?.completionBlock = {[weak self] dataReturned in
                    //Data is returned **Do anything with it **
                    print(dataReturned)
                }
    
        present(vc!, animated: true, completion: nil)

//        if !session!.isRunning {
//          DispatchQueue.global(qos: .default).async { [weak self] in
            self.session?.startRunning()
//          }
//        }
//
        // qwertyqwerty,get,http://aioty.in/scopex/image_data/qwertyqwerty.jpg
                //testdata
        
        
        
        //data
        //545826199
        //427557822
        
        
    }
    //
    //  LuckViewController.swift
    //  therealnft
    //
    //  Created by Macbook on 26/08/21.
    //
}
    extension ViewController  :CocoaMQTTDelegate{
        
        func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
            
            if ack == .accept   {
                
            print("<<<---------connecteduhh bro------------>>>")
                   // Fetch Image Data
    //            if (try? Data(contentsOf: URL(fileURLWithPath: yet!))) != nil {
                       // Create Image and Update Image View
    //                puthusu
//                do {
//                    sleep(10)
//                };
                mqtt.subscribe("scopex1", qos: CocoaMQTTQOS.qos1)

//                 mqtt.publish("scopex1", withString: yet!+",get,"+publishstringdaw!)

    //            mqtt.didReceiveMessage()
    //               }
            
            }
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
                
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
            
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
            print("XDXDXDMessage received in topic (" + message.topic + ") with payload (" + message.string! + ")")
            
            let fullName    = message.string
            let fullNameArr = fullName!.components(separatedBy: ",")

            if((fullNameArr[0]) == oldyet?.lowercased() && (fullNameArr[1] == "reply")){
                print("finalized"+fullNameArr[2])
                //comp?(fullNameArr[2])
                //NotificationCenter.default.post(name: Notification.Name(rawValue: "myNotificationKey"), object: self)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "myNotificationKey"), object: nil, userInfo: ["value" : fullNameArr[2]])

            }
            

        }
        
        func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
            
            print(topics)
            
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
            
        }
        
        func mqttDidPing(_ mqtt: CocoaMQTT) {
            
        }
        
        func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
            
            print("XDXDreceivepong_daw")
            
        }
        
        func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
            
        }

}

extension ViewController: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    if let error = error {
      print("error: \(error.localizedDescription)")
    } else {
        PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
          PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
          } completionHandler: { (success, error) in

          }
        }
      }
    }
  }
}


