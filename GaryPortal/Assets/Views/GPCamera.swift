//
//  GPCamera.swift
//  GaryPortal
//
//  Created by Tom Knighton on 11/02/2021.
//

import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    @GestureState private var isPressingDown: Bool = false
    
    @State var isShowingEditor = false
    @State var timeLimit = 30
    @State var allowsGallery = true
    @State var isShowingPicker = false
    var onFinalAction: (_ success: Bool, _ isVideo: Bool, _ urlToMedia: URL?) -> ()
    
    init(timeLimit: Int = 30, allowsGallery: Bool = true, _ finishedEditing: @escaping(_ success: Bool, _ isVideo: Bool, _ urlToMedia: URL?) -> ()) {
        self.onFinalAction = finishedEditing
        self.timeLimit = timeLimit
        self.allowsGallery = allowsGallery
    }
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture(count: 2) {
                    if !self.camera.isRecording && !self.camera.isTaken {
                        self.camera.toggleCamera()
                    }
                }
            
            VStack {
                HStack {
                    Spacer().frame(width: 8)
                    Button(action: { self.onFinalAction(false, false, nil) }, label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color("Section").opacity(0.6))
                            .clipShape(Circle())
                    })
                    .if(self.camera.isRecording) { $0.hidden() }
                    .padding(10)
                    
                    Spacer()
                    if !camera.isTaken && !camera.isRecording {
                        Button(action: { self.camera.toggleFlash()  }, label: {
                            Image(systemName: self.camera.flashModeImageName)
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color("Section").opacity(0.6))
                                .clipShape(Circle())
                        })
                        .padding(10)
                        Spacer().frame(width: 16)
                        Button(action: { self.camera.toggleCamera() }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color("Section").opacity(0.6))
                                .clipShape(Circle())
                        })
                        .padding(10)
                        
                    }
                    
                }
                HStack {
                    if !camera.isTaken && !camera.isRecording && self.allowsGallery {
                        Spacer()
                        Button(action: { self.isShowingPicker = true }, label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color("Section").opacity(0.6))
                                .clipShape(Circle())
                        })
                        .padding(10)
                    }
                }
                
                Spacer()
                HStack {
                    if !camera.isTaken {
                        Button(action: {  }, label: {
                            ZStack {
                                Circle()
                                    .fill(self.camera.isRecording ? Color.red : Color.white)
                                    .frame(width: self.camera.isRecording ? 85 : 65, height: self.camera.isRecording ? 85 : 65)
                                    .animation(.easeInOut)
                                Circle()
                                    .stroke(self.camera.isRecording ? Color.red :Color.white, lineWidth: 2)
                                    .frame(width: self.camera.isRecording ? 95 : 75, height: self.camera.isRecording ? 95 : 85)
                                    .animation(.easeInOut)
                            }
                            .onTapGesture(perform: {
                                self.camera.takePic()
                            })
                            
                            
                        })
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 1.0)
                                .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                                .updating($isPressingDown, body: { (value, state, transaction) in
                                    switch value {
                                    case .second(true, nil):
                                        state = true
                                    default: break
                                    }
                                })
                        )
                    }
                }
                .frame(height: 75)
                .onChange(of: self.isPressingDown, perform: { value in
                    if value { self.camera.startRecording() }
                    else { self.camera.stopRecording() }
                })
            }
            
            if self.camera.shouldShowEditor {
                MediaEditor(isShowing: Binding(get: { camera.shouldShowEditor} , set: {camera.shouldShowEditor = $0}), isVideo: self.camera.outputURL != nil, photoData: self.camera.picData, videoURL: self.camera.outputURL, wasFromLibrary: self.camera.wasFromLibrary, cameraUsed: self.camera.currentCamera, action: self.onFinalAction)
                    .onDisappear {
                        self.camera.reTake()
                    }
            }
        }
        .onAppear {
            camera.checkAccess(self.timeLimit)
        }
        .sheet(isPresented: $isShowingPicker) {
            MediaPicker(limit: 1, filter: .imagesAndVideos) { (didPick, items) in
                self.isShowingPicker = false
                if didPick {
                    if let items = items, let item = items.items.first {
                        if item.mediaType == .photo {
                            guard let imageData = item.photo?.jpegData(compressionQuality: 0.7) else { return }
                            
                            DispatchQueue.global(qos: .background).async {
                                self.camera.session.stopRunning()
                            }
                            self.camera.picData = imageData
                            self.camera.isTaken = true
                            self.camera.wasFromLibrary = true
                            self.camera.shouldShowEditor = true
                        } else if item.mediaType == .video {
                            DispatchQueue.main.async {
                                self.camera.session.stopRunning()
                                self.camera.outputURL = item.url
                                self.camera.isRecording = false
                                self.camera.picData = Data(count: 0)
                                self.camera.isTaken = true
                                self.camera.wasFromLibrary = true
                                self.camera.shouldShowEditor = true
                            }
                        }
                    }
                }
            }
        }
        .alert(isPresented: $camera.alert, content: {
            Alert(title: Text("Please enable camera"))
        })
    }
}

struct MediaEditor: View {
    
    @Environment(\.presentationMode) var presentationMode
    var isVideo = false
    var photoData: Data?
    var videoURL: URL?
    var cameraUsed: CameraPosition
    var wasFromLibrary: Bool
    
    @Binding var isShowing: Bool
    @State private var play = true
    @State private var chosenColour: Color = .clear
    @State private var drawingImage = UIImage()
    @State private var isInDrawingMode = false
    @State private var didDraw = false
    
    var onFinishedEditing: (_ success: Bool, _ isVideo: Bool, _ urlToMedia: URL?) -> ()
    
    init(isShowing: Binding<Bool>, isVideo: Bool = false, photoData: Data? = nil, videoURL: URL? = nil, wasFromLibrary: Bool, cameraUsed: CameraPosition, action: @escaping (_ success: Bool, _ isVideo: Bool, _ urlToMedia: URL?) -> ()) {
        self.isVideo = isVideo
        self.photoData = photoData
        self.videoURL = videoURL
        self.cameraUsed = cameraUsed
        self.onFinishedEditing = action
        self.wasFromLibrary = wasFromLibrary
        self._isShowing = isShowing
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black.edgesIgnoringSafeArea(.all)
                if isVideo {
                    PlayerView(url: videoURL?.absoluteString ?? "", play: $play, gravity: self.wasFromLibrary ? .fit : .fill)
                        .if(self.cameraUsed == .front) { $0.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    if let photoData = self.photoData {
                        Image(uiImage: UIImage(data: photoData) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .if(self.cameraUsed == .front) { $0.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) }
                    }
                }
                
                if !self.isVideo || (self.isVideo && !self.wasFromLibrary) {
                    DrawingViewRepresentable(isDrawing: $isInDrawingMode, finalImage: $drawingImage, didDraw: $didDraw)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    if !isInDrawingMode {
                        HStack(alignment: .top) {
                            Spacer().frame(width: 8)
                            Button(action: { self.isShowing = false }, label: {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color("Section"))
                                    .clipShape(Circle())
                                    .padding(.top, 24)
                            })
                            
                            Spacer()
                            Button(action: { self.isInDrawingMode = true }, label: {
                                Image(systemName: "pencil.and.outline")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color("Section"))
                                    .clipShape(Circle())
                                    .padding(.top, 24)
                            })
                            .if(self.isVideo && self.wasFromLibrary) { $0.hidden() }

                            Spacer().frame(width: 16)
                        }
                        .animation(.easeInOut)
                        .padding(.top, 32)
                    } else {
                        HStack(alignment: .top) {
                            Spacer()
                            Button(action: { self.isInDrawingMode = false }, label: {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color("Section"))
                                    .clipShape(Circle())
                                    .padding(.top, 24)
                            })
                            Spacer().frame(width: 16)
                        }
                        .animation(.easeInOut)
                        .padding(.top, 32)
                    }
                    Spacer()
                    if !isInDrawingMode {
                        HStack {
                            Spacer()

                            Button(action: { finishEditing() }, label: {
                                HStack {
                                    Text("Next")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .clipShape(Capsule())
                            })
                            .padding(.leading)
                            Spacer().frame(width: 8)
                        }
                    }
                    Spacer().frame(height: 32)
                }
                
                
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func finishEditing() {
        if isVideo {
            guard let videoURL = self.videoURL else { self.onFinishedEditing(false, true, nil); return }
            let asset = AVURLAsset(url: videoURL)
            let composition = AVMutableComposition()
            guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                  let assetTrack = asset.tracks(withMediaType: .video).first else { self.onFinishedEditing(false, true, nil); return }
            
            do {
                let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
                try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
                if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
                   let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try compositionAudioTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: .zero)
                }
                
                compositionTrack.preferredTransform = assetTrack.preferredTransform
                let videoInfo = orientation(from: assetTrack.preferredTransform)
                
                let videoSize: CGSize
                let screenSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                if videoInfo.isPortrait {
                    videoSize = CGSize(
                        width: assetTrack.naturalSize.height,
                        height: assetTrack.naturalSize.width)
                } else {
                    print("horizontal")
                    videoSize = assetTrack.naturalSize
                }
                
                let videoLayer = CALayer()
                videoLayer.frame = CGRect(origin: .zero, size: videoSize)
                let overlayLayer = CALayer()
                overlayLayer.frame = CGRect(origin: .zero, size: screenSize)
                overlayLayer.contents = self.drawingImage.cgImage
                
                let outputLayer = CALayer()
                outputLayer.frame = CGRect(origin: .zero, size: videoSize)
                outputLayer.addSublayer(videoLayer)
                outputLayer.addSublayer(overlayLayer)
                
                let videoComposition = AVMutableVideoComposition()
                videoComposition.renderSize = videoSize
                videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
                videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: outputLayer)
                
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRange(start: .zero, end: composition.duration)
                videoComposition.instructions = [instruction]
                let layerInstruction = compositionLayerInstruction(for: compositionTrack, assetTrack: assetTrack)
                instruction.layerInstructions = [layerInstruction]
                
                guard let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality) else { return }
                let videoName = UUID().uuidString
                let exportURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(videoName).appendingPathExtension("mp4")
                export.videoComposition = videoComposition
                export.outputFileType = .mp4
                export.outputURL = exportURL
                
                export.exportAsynchronously {
                    DispatchQueue.main.async {
                        switch export.status {
                        case .completed:
                            self.onFinishedEditing(true, true, exportURL)
                            break
                        default:
                            self.onFinishedEditing(false, true, nil)
                            break
                        }
                    }
                }
                
            } catch {
                self.onFinishedEditing(false, true, nil)
            }
        } else {
            if let photoData = self.photoData {
                let oldImage = UIImage(data: photoData)
                let newImage = oldImage?.imageByCombiningImage(withImage: self.drawingImage)
                let fileUrl = newImage?.saveImageToDocumentsDirectory(withName: UUID().uuidString)
                if let url = URL(string: fileUrl ?? "") {
                    self.onFinishedEditing(true, false, url)
                } else {
                    self.onFinishedEditing(false, false, nil)
                }
            }
        }
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        
        instruction.setTransform(transform, at: .zero)
        
        return instruction
    }
    
    private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        
        return (assetOrientation, isPortrait)
    }
}

class DrawingView: UIView, ColourPickerDelegate {
    
    var lastPoint: CGPoint = .zero
    var colour: Color = .black
    var brushWidth: CGFloat = 10
    var opacity: CGFloat = 1
    var swiped = false
    var isDrawing = false
    
    var mainImageView = UIImageView()
    var tempImageView = UIImageView()
    var imageSteps = [UIImage]()
    
    var colourPickerView: UIView?
    var backButton: UIButton?
    
    var delegate: DrawingViewProtocol?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(mainImageView)
        self.addSubview(tempImageView)
        self.mainImageView.bindFrameToSuperviewBounds()
        self.tempImageView.bindFrameToSuperviewBounds()
        
        let hostVC = UIHostingController(rootView: ColourPickerView(chosenColor: colour, delegate: self))
        self.colourPickerView = hostVC.view
        if let colourview = self.colourPickerView {
            self.addSubview(colourview)
            self.bringSubviewToFront(colourview)
            colourview.backgroundColor = .clear
            colourview.translatesAutoresizingMaskIntoConstraints = false
            colourview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14).isActive = true
            colourview.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        }
        self.backButton = UIButton()
        backButton?.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let backImage = UIImage(systemName: "arrow.uturn.backward", withConfiguration: largeConfig)
        backButton?.setImage(backImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton?.tintColor = .white
        self.addSubview(backButton ?? UIButton())
        self.bringSubviewToFront(backButton ?? UIButton())
        backButton?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        backButton?.topAnchor.constraint(equalTo: self.topAnchor, constant: 72).isActive = true
        backButton?.heightAnchor.constraint(equalToConstant: 45).isActive = true
        backButton?.widthAnchor.constraint(equalToConstant: 45).isActive = true
        backButton?.backgroundColor = .clear
        backButton?.addTarget(self, action: #selector(self.backButtonPressed(_:)), for: .touchUpInside)
        
    }
    
    public func toggleDrawing(mode: Bool) {
        self.isDrawing = mode
        self.colourPickerView?.isHidden = !mode
        self.backButton?.isHidden = !mode
    }
    
    @objc
    func backButtonPressed(_ sender: UIButton) {
        self.mainImageView.image = self.imageSteps.popLast()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, self.isDrawing == true else { return }
        
        swiped = false
        lastPoint = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, self.isDrawing == true else { return }
        
        swiped = true
        let currentPoint = touch.location(in: self)
        self.drawLine(from: self.lastPoint, to: currentPoint)
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.isDrawing == true else { return }
        
        if !swiped {
            self.drawLine(from: self.lastPoint, to: self.lastPoint)
        }
        
        UIGraphicsBeginImageContext(self.mainImageView.frame.size)
        self.mainImageView.image?.draw(in: self.bounds, blendMode: .normal, alpha: 1.0)
        self.tempImageView.image?.draw(in: self.bounds, blendMode: .normal, alpha: self.opacity)
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.tempImageView.image = nil
        self.imageSteps.append(self.mainImageView.image ?? UIImage())
        self.delegate?.didUpdateImage(self.mainImageView.image ?? UIImage())
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        guard self.isDrawing == true else { return }
        
        UIGraphicsBeginImageContext(self.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        self.tempImageView.image?.draw(in: self.bounds)
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(self.brushWidth)
        context.setStrokeColor(UIColor(self.colour).cgColor)
        context.strokePath()
        self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempImageView.alpha = self.opacity
        UIGraphicsEndImageContext()
    }
    
    func didChangeColour(to colour: Color) {
        self.colour = colour
    }
}

protocol DrawingViewProtocol {
    func didUpdateImage(_ image: UIImage)
}
struct DrawingViewRepresentable: UIViewRepresentable {
    
    @Binding var isDrawing: Bool
    
    @Binding var finalImage: UIImage
    @Binding var didDraw: Bool
    
    
    func makeUIView(context: Context) -> DrawingView {
        let view = DrawingView()
        view.isDrawing = isDrawing
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: DrawingView, context: Context) {
        uiView.toggleDrawing(mode: self.isDrawing)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, DrawingViewProtocol {
        var parent: DrawingViewRepresentable
        
        init(_ parent: DrawingViewRepresentable) {
            self.parent = parent
        }
        
        func didUpdateImage(_ image: UIImage) {
            parent.finalImage = image
            self.parent.didDraw = true
        }
    }
}
