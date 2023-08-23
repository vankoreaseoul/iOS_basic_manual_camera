//
//  FrameVM.swift
//  CameraTest
//
//  Created by Heawon Seo on 2023/08/16.
//

import Foundation
import AVFoundation
import CoreImage

class LiveCameraVM: NSObject, ObservableObject {
    
    enum CameraProperty {
        case FOCUS, EXPOSURE, WB
    }
    
    enum WhiteBalanceOption {
        case TEMPERATURE, RGB
    }
    
    // Camera
    @Published var frame: CGImage?
    private var permissionGranted = false {
        didSet {
            guard permissionGranted else { return }
            sessionQueue.async { [unowned self] in
                self.setupCaptureSession()
                self.captureSession.startRunning()
            }
        }
    }
    
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    private var device: AVCaptureDevice? = nil
    
    // Layout
    @Published var indicatorState: CameraProperty? = nil
    @Published var wbOption: WhiteBalanceOption? = nil
    var sliderPadding: CGFloat = 40
    var indicatorRadius: CGFloat = 30
    
        // MARK: - Focus
    @Published var focusOffset: CGFloat = 0 {
        didSet {
            let halfLengthOfSlider = UIScreenSize.width/2 - sliderPadding - indicatorRadius/2
            let lensePosition = (focusOffset + halfLengthOfSlider)/(halfLengthOfSlider * 2)
            self.lensePosition = Float(lensePosition)
        }
    }
    @Published var lensePosition: Float = 0.5 {
        didSet {
            adjustFocus(device: device!, lensePosition: lensePosition)
        }
    }
        // MARK: - Exposure
    // 1. Shutter Speed
    @Published var expoSSOffset: CGFloat = 0 {
        didSet {
            let barLength = UIScreenSize.width - 2*sliderPadding - indicatorRadius
            expoSSConstant = Int32(1000 - ((1000 - 1) / barLength * expoSSOffset))
        }
    }
    @Published var expoSSConstant: Int32 = 1000 {
        didSet {
            adjustExpoSS(device: device!, ss_value: expoSSConstant)
        }
    }
    
    // 2. ISO
    private var minimumISO: Float = 0.0 {
        didSet {
            Log("minISO = \(minimumISO)")
        }
    }
    private var maximumISO: Float = 0.0 {
        didSet {
            Log("maxISO = \(maximumISO)")
        }
    }
    @Published var expoIsoOffset: CGFloat = 0 {
        didSet {
            expoIsoConstant = Float(expoIsoOffset) * (maximumISO - minimumISO) / Float(UIScreenSize.width - 2*sliderPadding - indicatorRadius) + minimumISO
        }
    }
    @Published var expoIsoConstant: Float = 0.0 {
        didSet {
            adjustExpoISO(device: device!, iso: expoIsoConstant)
        }
    }
    
    // 3. f - stop
    @Published var f_value: Float = 0.0
    
    // MARK: - White Balance
        // 1. RGB
    private var maximumWbGain: Float = 0.0 {
        didSet {
            Log("maxWB = \(maximumWbGain)")
        }
    }
    @Published var redOffset: CGFloat = 0
    {
        didSet {
            redConstant = Float(redOffset) * (maximumWbGain - 1) / Float(UIScreenSize.width - 2*sliderPadding - indicatorRadius) + 1
        }
    }
    @Published var greenOffset: CGFloat = 0
    {
        didSet {
            greenConstant = Float(greenOffset) * (maximumWbGain - 1) / Float(UIScreenSize.width - 2*sliderPadding - indicatorRadius) + 1
        }
    }
    @Published var blueOffset: CGFloat = 0
    {
        didSet {
            blueConstant = Float(blueOffset) * (maximumWbGain - 1) / Float(UIScreenSize.width - 2*sliderPadding - indicatorRadius) + 1
        }
    }
    @Published var redConstant: Float = 1.0
    {
        didSet {
            adjustWBByRGB(device: device!, red: redConstant, green: greenConstant, blue: blueConstant)
        }
    }
    @Published var greenConstant: Float = 1.0
    {
        didSet {
            adjustWBByRGB(device: device!, red: redConstant, green: greenConstant, blue: blueConstant)
        }
    }
    @Published var blueConstant: Float = 1.0
    {
        didSet {
            adjustWBByRGB(device: device!, red: redConstant, green: greenConstant, blue: blueConstant)
        }
    }
        // 2. Temp
    @Published var selectedTemp: Float = 0.0

    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
        
        checkFvalue()
    }
    
    // MARK: - Usual Func
    /// Camera Focus Set
    func adjustFocus(device: AVCaptureDevice, lensePosition: Float) {
        do {
            try device.lockForConfiguration()
            
//            let currentLensPosition = AVCaptureDevice.currentLensPosition
//            let lensPosition = device.lensPosition
//            device.focusMode = .autoFocus
//            Log("currentLensPosition = \(currentLensPosition)")
//            Log("lensPosition = \(lensPosition)")
//            Log("device.position = \(device.position)")
            
            device.setFocusModeLocked(lensPosition: lensePosition)
        
            device.unlockForConfiguration()
        } catch {
            Log("Error adjusting focus: \(error)")
        }
    }
    
    /// Camera Exposure Set
    func adjustExpoSS(device: AVCaptureDevice, ss_value: Int32) {
        do {
            try device.lockForConfiguration()
            
            device.exposureMode = .custom
            device.setExposureModeCustom(duration: CMTime(value: 1, timescale: ss_value), iso: expoIsoConstant)
            
            device.unlockForConfiguration()
        } catch {
            Log("Error adjusting exposureSS: \(error)")
        }
    }
    
    func adjustExpoISO(device: AVCaptureDevice, iso: Float) {
        do {
            try device.lockForConfiguration()
            
            device.exposureMode = .custom
            device.setExposureModeCustom(duration: CMTime(value: 1, timescale: expoSSConstant), iso: iso)
            
            device.unlockForConfiguration()
        } catch {
            Log("Error adjusting exposureISO: \(error)")
        }
    }
    
    /// Camera White Balance Set
    func adjustWBByRGB(device: AVCaptureDevice, red: Float, green: Float, blue: Float) {
        do {
            try device.lockForConfiguration()
            
            device.whiteBalanceMode = .locked
            let whiteBalanceGain = AVFoundation.AVCaptureDevice.WhiteBalanceGains(redGain: red, greenGain: green, blueGain: blue)
            device.setWhiteBalanceModeLocked(with: whiteBalanceGain, completionHandler: nil)
            
            device.unlockForConfiguration()
        } catch {
            Log("Error adjusting WB by RGB: \(error)")
        }
    }
    
    func adjustWBByTemp(device: AVCaptureDevice, temperatures: Float, tint: Float) {
        do {
            try device.lockForConfiguration()
            
            device.whiteBalanceMode = .locked
            
            let temper1 = AVFoundation.AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: temperatures, tint: tint)
            let rgb1 = device.deviceWhiteBalanceGains(for: temper1)
            device.setWhiteBalanceModeLocked(with: rgb1, completionHandler: nil)
            
            device.unlockForConfiguration()
            
            selectedTemp = temperatures
        } catch {
            Log("Error adjusting WB by Temp: \(error)")
        }
    }
    
    func didTapFocusBtn() {
        if indicatorState == nil || indicatorState == .EXPOSURE || indicatorState == .WB {
            indicatorState = .FOCUS
        } else if indicatorState == .FOCUS {
            indicatorState = nil
        }
    }
    
    func didTapExposureBtn() {
        if indicatorState == nil || indicatorState == .FOCUS || indicatorState == .WB {
            indicatorState = .EXPOSURE
        } else if indicatorState == .EXPOSURE {
            indicatorState = nil
        }
    }
    
    func didTapWBBtn() {
        if indicatorState == nil || indicatorState == .FOCUS || indicatorState == .EXPOSURE {
            indicatorState = .WB
            wbOption = nil
        } else if indicatorState == .WB {
            indicatorState = nil
        }
    }
    
    func didTapTempBtn() {
        wbOption = .TEMPERATURE
        
        if selectedTemp == 0.0 {
            adjustWBByTemp(device: device!, temperatures: 3200, tint: 0)
        } else {
            adjustWBByTemp(device: device!, temperatures: selectedTemp, tint: 0)
        }
    }
    
    func didTapTmpConstantBtn(temp: Float) {
        adjustWBByTemp(device: device!, temperatures: temp, tint: 0)
    }
    
    func didTapRGBBtn() {
        wbOption = .RGB
        adjustWBByRGB(device: device!, red: redConstant, green: greenConstant, blue: blueConstant)
    }

    func didTapShutterBtn() {
        
    }
    
    func addObserverForFvalue(device: AVCaptureDevice) {
        DispatchQueue.main.async {
            self.f_value = device.lensAperture
        }
        
        let _ = device.observe(\.lensAperture) { device_1, change in
                                        if let newAperture = change.newValue {
                                            DispatchQueue.main.async {
                                                self.f_value = newAperture
                                            }
                                        }
                                   }
    }
    
    // For Case that F_value observer doesn't work
    func checkFvalue() {
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getFvalue), userInfo: nil, repeats: true)
    }

    @objc func getFvalue() {
        Log("f_value = \(device!.lensAperture)")
    }
    
    
    // MARK: - Camera Func
    /// Check authorization for Camera
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    /// For Case that the user doesn't allow
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    /// In case that the user did allow, set camera session
    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        
        // Supported Camera
        // .builtInWideAngleCamera
        
        // UnSupported Camera
        // .builtInDualWideCamera
        // .builtInUltraWideCamera
        // ...
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let hasDevice = device else {
            Log("Error: The type of camera is not supported!")
            return
        }
        
        // Input
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: hasDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        // Configure
        if configureCamera(device: hasDevice) {
            
            // Output
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
            captureSession.addOutput(videoOutput)
            
            videoOutput.connection(with: .video)?.videoOrientation = .portrait
        }
    }
    
    /// Camera Configuration - It's called only once at first
    func configureCamera(device: AVCaptureDevice) -> Bool {
        // Check if what to use is supported or not
        // If the error code is 'Unsupport' -> Check what kinds of camera you choose!
        let isFocusSettingEnable = device.isLockingFocusWithCustomLensPositionSupported
        let isExposureSettingEnable = device.isExposureModeSupported(.custom)
        let isWhiteBalanceSettingEnable = device.isLockingWhiteBalanceWithCustomDeviceGainsSupported

        minimumISO = device.activeFormat.minISO
        maximumISO = device.activeFormat.maxISO

        maximumWbGain = device.maxWhiteBalanceGain
        
        addObserverForFvalue(device: device)
        
        if isFocusSettingEnable && isExposureSettingEnable && isWhiteBalanceSettingEnable {
            adjustFocus(device: device, lensePosition: lensePosition)
            DispatchQueue.main.async {
                self.expoIsoConstant = self.minimumISO
                self.adjustExpoSS(device: device, ss_value: self.expoSSConstant)
            }
            return true
        } else {
            return false
        }
    }
    
    
}

extension LiveCameraVM: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return cgImage
    }
    
}
