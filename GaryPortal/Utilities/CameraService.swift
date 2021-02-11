//
//  CameraService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 11/02/2021.
//

import SwiftUI
import Foundation
import AVFoundation
import Photos

public enum CameraPosition {
    case front
    case back
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var output = AVCapturePhotoOutput()
    @Published var movieOutput = AVCaptureMovieFileOutput()
    
    var outputURL: URL?
    
    
    @Published var currentCamera: CameraPosition = .back
    private var currentDeviceInput: AVCaptureDeviceInput?
    
    // preview....
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    @Published var alert = false
    
    @Published var isSaved = false
    
    @Published var picData = Data(count: 0)
    
    @Published var isRecording = false
    
    @Published var flashModeImageName = "bolt.slash"
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    
    @Published var shouldShowEditor = false
    
    func checkAccess() {
        
        // first checking camerahas got permission...
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
            return
            // Setting Up Session
        case .notDetermined:
            // retusting for permission....
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                
                if status{
                    self.setup()
                }
            }
        case .denied:
            alert = true
            return
            
        default:
            return
        }
    }
    
    func setup(){
        
        // setting up camera...
        
        do{
            
            // setting configs...
            self.session.beginConfiguration()
            
            // change for your own...
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            let mic = AVCaptureDevice.default(for: .audio)
            let input = try AVCaptureDeviceInput(device: device!)
            let micInput = try AVCaptureDeviceInput(device: mic!)
            // checking and adding to session...
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
                self.currentDeviceInput = input
            }
            if self.session.canAddInput(micInput) {
                self.session.addInput(micInput)
            }
            
            // same for output....
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            if self.session.canAddOutput(self.movieOutput) {
                self.session.addOutput(self.movieOutput)
            }
            
            self.session.commitConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func toggleCamera() {
        guard let currentInput = self.currentDeviceInput else { return }
        do {
            switch self.currentCamera {
            case .back:
                self.session.removeInput(currentInput)
                if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    let newInput = try AVCaptureDeviceInput(device: device)
                    self.session.addInput(newInput)
                    self.currentDeviceInput = newInput
                    self.currentCamera = .front
                }
                break
            case .front:
                self.session.removeInput(currentInput)
                if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    let newInput = try AVCaptureDeviceInput(device: device)
                    self.session.addInput(newInput)
                    self.currentDeviceInput = newInput
                    self.currentCamera = .back
                }
                break
            }
        } catch {
            print("Error")
        }
        
    }
    
    func toggleFlash() {
        switch self.flashMode {
        case .auto:
            self.flashMode = .on
            self.flashModeImageName = "bolt"
            break
        case .on:
            self.flashMode = .off
            self.flashModeImageName = "bolt.slash"
            break
        case .off:
            self.flashMode = .auto
            self.flashModeImageName = "bolt.badge.a"
            break
        @unknown default:
            self.flashMode = .on
            self.flashModeImageName = "bolt"
            break
        }
    }
    
    func startRecording() {
        self.isRecording = true
        FileManager.default.clearTmpDirectory()
        self.outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempfilm").appendingPathExtension("mp4").absoluteURL
        if let url = outputURL {
            self.movieOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    func stopRecording() {
        self.isRecording = false
        self.movieOutput.stopRecording()
    }
        
    func takePic() {
        if self.output.supportedFlashModes.contains(self.flashMode) {
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            settings.flashMode = self.flashMode
            self.output.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func reTake(){
        
        DispatchQueue.global(qos: .background).async {
            
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isTaken = false
                self.isSaved = false
                self.picData = Data(count: 0)
                self.outputURL = nil
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("") // If this print statement is removed the data fails to process..........
        if error != nil {
            return
        }
        guard let imageData = photo.fileDataRepresentation() else { return }

        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
        }
        self.picData = imageData
        self.isTaken = true
        self.shouldShowEditor = true
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.picData = Data(count: 0)
            self.isTaken = true
            self.isSaved = true
            self.shouldShowEditor = true
        }
    }
    
    
    func savePic(){
        
        guard let image = UIImage(data: self.picData) else { return }
        
        // saving Image...
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
    }
}

// setting view for preview...

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera : CameraModel
    
    func makeUIView(context: Context) ->  UIView {
     
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        // Your Own Properties...
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        // starting session
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
