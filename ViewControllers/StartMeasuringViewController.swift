//
//  ViewController.swift
//  HeartRate
//
//  Created by Ирина Савчик on 21.05.21.
//

import UIKit
import Haptica
import AVFoundation

enum MeasureStateType {
    case MEASURING
    case MEASURED
    case ERROR
    case STANDBY
}

class StartMeasuringViewController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var heartView: UIImageView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var pulseCounterLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var startMeasureButton: UIButton!
    
    private var heartRateManager: HeartRateManager!
    private var hueFilter = Filter()
    private var pulseDetector = PulseDetector()
    private var inputs: [CGFloat] = []
    private var measurementStartedFlag = false
    private var timer = Timer()
    private var timeoutTimer = Timer()
    private var validFrameCounter = 0
    
    private var currentMeasurementState = MeasureStateType.STANDBY
    private let subManager = SubscriptionManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subManager.verifySubscription()
        
        changeMeasureState(state: MeasureStateType.STANDBY)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        if Settings.shared.firstLaunch {
            self.performSegue(withIdentifier: "mainTutorial", sender: self)
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Settings.shared.firstSubscription && !Settings.shared.firstLaunch {
            self.performSegue(withIdentifier: "mainSubscriptionSegue", sender: self)
            Settings.shared.firstSubscription = false
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBAction func startActionButton(_ sender: Any) {
        self.subManager.verifySubscription()
        Settings.shared.checkMeasurementCount()
        
        if Settings.shared.hasSubscription || Settings.shared.canMeasured {
            changeMeasureState(state: MeasureStateType.MEASURING)
            self.progress.setProgress(0.001, animated: true)
            self.pulseCounterLabel.text = "00"
            initVideoCapture()
            initCaptureSession() // подключается к камере
        } else {
            super.performSegue(withIdentifier: "mainSubscriptionSegue", sender: self)
        }
    }
    
    @IBAction func settingsActionButton(_ sender: Any) {
        self.performSegue(withIdentifier: "settings", sender: self)
    }
    
    @IBAction func historyActionButton(_ sender: Any) {
        self.performSegue(withIdentifier: "history", sender: self)
    }
    
    private func changeMeasureState(state: MeasureStateType) {
        self.currentMeasurementState = state
        switch state {
        case .ERROR:
            pulseCounterLabel.show()
            firstLabel.show()
            secondLabel.show()
            secondLabel.text = "Place your finger on the camera and flash"
            secondLabel.textColor =
                UIColor.init(red: 249/255, green: 48/255, blue: 84/255, alpha: 1)
            progress.show()
            startLabel.hide()
            startMeasureButton.hide()
        case .MEASURED:
            validFrameCounter = 0
            pulseCounterLabel.show()
            firstLabel.show()
            secondLabel.hide()
            progress.hide()
            startLabel.hide()
            startMeasureButton.show()
            startMeasureButton.setTitle("Repeat",for: UIControl.State.normal)
        case .MEASURING:
            pulseCounterLabel.show()
            firstLabel.show()
            secondLabel.show()
            secondLabel.text = "measuring the pulse..."
            secondLabel.textColor = .black
            progress.show()
            startMeasureButton.hide()
            startLabel.hide()
            vibrationWhileMeasuring()
        case .STANDBY:
            pulseCounterLabel.hide()
            secondLabel.hide()
            progress.hide()
            firstLabel.hide()
            startLabel.show()
            startMeasureButton.show()
            startMeasureButton.setTitle("Start",for: UIControl.State.normal)
        }
    }
    
    private func vibrationWhileMeasuring() {
        Haptic.play("-oO--Oo", delay: 0.5)
    }
    
    private func initVideoCapture() {
        let specs = VideoSpec(fps: 30, size: CGSize(width: 300, height: 300))
        heartRateManager = HeartRateManager(cameraType: .back, preferredSpec: specs, previewContainer: cameraView.layer)
        heartRateManager.imageBufferHandler = { [unowned self] (imageBuffer) in
            self.handle(buffer: imageBuffer)
        }
    }
    
    private func initCaptureSession() {
        heartRateManager.startCapture()
    }
    
    private func deinitCaptureSession() {
        heartRateManager.stopCapture()
        heartRateManager.imageBufferHandler = nil
        toggleTorch(status: false)
    }
    
    private func toggleTorch(status: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        device.toggleTorch(on: status)
    }
    
    private func startMeasurement() {
        DispatchQueue.main.async {
            var counter = 0
            self.toggleTorch(status: true)
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
                counter += 1
                guard let self = self else { return }
                
                let average = self.pulseDetector.getAverage()
                let pulse = 60.0/average
                
                if self.measurementStartedFlag {
                    self.progress.setProgress(self.progress.progress + 0.1, animated: true)
                }
                
                if pulse > 0 {
                    self.timer.invalidate()
                    self.timeoutTimer.invalidate()
                    
                    self.deinitCaptureSession()
                    
                    RealmManager.shared.writeObject(measure: Measure(beatsPerMinute: lroundf(pulse)))
                    
                    self.progress.setProgress(1, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Settings.shared.onMeasured()
                        self.changeMeasureState(state: MeasureStateType.MEASURED)
                        self.toggleTorch(status: false)
                    }
                    self.pulseCounterLabel.text = "\(lroundf(pulse))"
                } else if counter % 2 == 0 {
                    self.pulseCounterLabel.text = "\(Int.random(in: 40...120))"
                }
            })
        }
    }
}

extension StartMeasuringViewController {
    
    fileprivate func handle(buffer: CMSampleBuffer) {
        var redmean: CGFloat = 0.0;
        var greenmean: CGFloat = 0.0;
        var bluemean: CGFloat = 0.0;
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        let extent = cameraImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let averageFilter = CIFilter(name: "CIAreaAverage",
                                     parameters: [kCIInputImageKey: cameraImage, kCIInputExtentKey: inputExtent])!
        let outputImage = averageFilter.outputImage!
        
        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(outputImage, from:outputImage.extent)!
        
        let rawData:NSData = cgImage.dataProvider!.data!
        let pixels = rawData.bytes.assumingMemoryBound(to: UInt8.self)
        let bytes = UnsafeBufferPointer<UInt8>(start:pixels, count:rawData.length)
        var BGRA_index = 0
        for pixel in UnsafeBufferPointer(start: bytes.baseAddress, count: bytes.count) {
            switch BGRA_index {
            case 0:
                bluemean = CGFloat (pixel)
            case 1:
                greenmean = CGFloat (pixel)
            case 2:
                redmean = CGFloat (pixel)
            case 3:
                break
            default:
                break
            }
            BGRA_index += 1
        }
        
        let hsv = rgb2hsv((red: redmean, green: greenmean, blue: bluemean, alpha: 1.0))
        // Do a sanity check to see if a finger is placed over the camera
        if (hsv.1 > 0.5 && hsv.2 > 0.5) {
            DispatchQueue.main.async {
                self.changeMeasureState(state: MeasureStateType.MEASURING)
                self.toggleTorch(status: true)
                
                if !self.measurementStartedFlag {
                    self.startMeasurement()
                    self.timeoutTimer.invalidate()
                    self.measurementStartedFlag = true
                }
            }
            
            validFrameCounter += 1
            inputs.append(hsv.0)
            let filtered = hueFilter.processValue(value: Double(hsv.0))
            if validFrameCounter > 60 {
               let value = self.pulseDetector.addNewValue(newVal: filtered, atTime: CACurrentMediaTime())
                print("Frame value \(value)")
            }
        } else if currentMeasurementState != MeasureStateType.STANDBY {
            
            if measurementStartedFlag {
                self.timeoutTimer.invalidate()
                DispatchQueue.main.async {
                    self.timeoutTimer = Timer.scheduledTimer(
                        withTimeInterval: 5.0,
                        repeats: false,
                        block: { (timer) in
                            self.deinitCaptureSession()
                            self.changeMeasureState(state: MeasureStateType.STANDBY)
                        })
                }
            }
            validFrameCounter = 0
            measurementStartedFlag = false
            pulseDetector.reset()
            self.timer.invalidate()
            
            DispatchQueue.main.async {
                if self.currentMeasurementState != MeasureStateType.STANDBY {
                    self.progress.setProgress(0.001, animated: true)
                    self.changeMeasureState(state: MeasureStateType.ERROR)
                }
            }
        }
    }
}

