//
//  SubmitButton.swift
//
//  Created by Jagajith M Kalarickal on 02/12/16.
//  Copyright © 2016 qbuser. All rights reserved.
//

import UIKit


public enum ButtonState {
    case ready
    case loading
    case finishing
    case finished
}

private struct Constants {
    
    static let contextID   = "kAnimationIdentifier"
    static let layerAnimation = "kLayerAnimation"
    static let prepareLoadingAnimDuration: TimeInterval = 0.2
    static let resetLinesPositionAnimDuration: TimeInterval = 0.2
    static let finishLoadingAnimDuration: TimeInterval  = 0.3
    static let bounceDuration: TimeInterval  = 0.3
    static let borderWidth: CGFloat = 5
    static let minFontSize: CGFloat = 17
    static let maxFontSize: CGFloat = 19
    static let minOpacity: Float = 0
    static let maxOpacity: Float = 1
    static let minStrokeEndPosition: CGFloat = 0
    static let maxStrokeEndPosition: CGFloat = 1
    static let requestDuration: CGFloat = 1.0
    static let frequencyUpdate: CGFloat = 0.1
}

private struct AnimKeys {
    static let bounds = "bounds"
    static let backgroundColor = "backgroundColor"
    static let position = "position"
    static let lineRotation = "lineRotation"
    static let transform = "transform"
    static let borderWidth = "borderWidth"
}

enum AnimContext: String {
    case LoadingStart
    case LoadingFinishing
}

@IBDesignable
open class SubmitButton: UIButton {
    
    // MARK: - Public variables
    
    /// color of dots and line in loading state
    @IBInspectable open var crDotColor: UIColor = #colorLiteral(red: 0, green: 0.8250309825, blue: 0.6502585411, alpha: 1)
    /// line width of the border
    @IBInspectable open var crLineWidth: CGFloat = 5
    /// border Color
    @IBInspectable open var crBorderColor: UIColor = #colorLiteral(red: 0, green: 0.8250309825, blue: 0.6502585411, alpha: 1) {
        didSet {
            borderLayer.borderColor = crBorderColor.cgColor
        }
    }
    @IBInspectable open var startText:String = "Submit"
    /// will clear after calling
    open var completionHandler: (()->())?
    open var currState: ButtonState {
        return buttonState
    }
    
    open var frequencyOfUpdate: CGFloat {
        return Constants.frequencyUpdate
    }
    
    // MARK: - Private Vars
    fileprivate lazy var borderLayer: CALayer = {
        let layer =  CALayer()
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = self.crBorderColor.cgColor
        layer.backgroundColor = nil
        return layer
    }()
    
    fileprivate lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = self.crDotColor.cgColor
        layer.bounds = self.circleBounds
        layer.path = UIBezierPath(arcCenter: self.boundsCenter, radius: self.boundsCenter.y - self.crLineWidth / 2,
                                  startAngle: CGFloat(-M_PI_2), endAngle: 3*CGFloat(M_PI_2), clockwise: true).cgPath
        layer.strokeEnd = Constants.minStrokeEndPosition
        layer.lineCap = kCALineCapRound
        layer.lineWidth = self.crLineWidth
        return layer
    }()
    
    fileprivate lazy var checkMarkLayer: CAShapeLayer = {
        return self.createCheckMark()
    }()
    
    
    fileprivate var buttonState: ButtonState = .ready {
        didSet {
            handleButtonState( buttonState )
        }
    }
    
    fileprivate var circleBounds: CGRect {
        var newRect = startBounds
        newRect?.size.width = startBounds.height
        return newRect!
    }
    
    fileprivate var boundsCenter: CGPoint {
        return CGPoint(x: circleBounds.midX, y: circleBounds.midY)
    }
    
    fileprivate var boundsStartCenter: CGPoint {
        return CGPoint(x: startBounds.midX, y: startBounds.midY)
    }
    
    // Constraints for button
    fileprivate var conWidth:  NSLayoutConstraint!
    fileprivate var conHeight: NSLayoutConstraint!
    fileprivate var startBounds: CGRect!
    fileprivate var startBackgroundColor: UIColor! = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    fileprivate var startTitleColor: UIColor! = #colorLiteral(red: 0, green: 0.8250309825, blue: 0.6502585411, alpha: 1)
    fileprivate let prepareGroup = DispatchGroup()
    fileprivate let finishLoadingGroup = DispatchGroup()
    
    var progress: CGFloat = 0
    var timer: Timer?
    
    func updateLoadingProgress() {
        guard progress <= 1 else {
            timer?.invalidate()
            self.stopAnimate()
            progress = 0
            return
        }
        progress += self.progressPerFrequency
        self.updateProgress( progress )
    }
    
    
    // MARK: - UIButton
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCommon()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupCommon()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if buttonState == .ready {
            layoutStartBounds()
        }
        layer.cornerRadius = bounds.midY
    }
    
    // MARK: - Public Methods
    
    open func resetToReady() {
        buttonState = .ready
        borderLayer.removeAllAnimations()
        layer.removeAllAnimations()
        checkMarkLayer.removeAllAnimations()
        clearLayerContext()
        CATransaction.begin()
        CATransaction.setDisableActions( true )
        layer.backgroundColor = startBackgroundColor.cgColor
        checkMarkLayer.opacity = Constants.minOpacity
        borderLayer.borderWidth = Constants.borderWidth
        borderLayer.borderColor = crBorderColor.cgColor
        progressLayer.removeFromSuperlayer()
        progressLayer.strokeEnd = Constants.minStrokeEndPosition
        CATransaction.commit()
        setTitle(startText, for: UIControlState())
        setTitleColor(startTitleColor, for: UIControlState())
        titleLabel?.layer.opacity = Constants.maxOpacity
    }
    
    open func startAnimate() {
        if buttonState != .ready {
            resetToReady()
        }
        buttonState = .loading
    }
    
    open func stopAnimate() {
        guard buttonState != .finishing && buttonState != .finished else {
            return
        }
        buttonState = .finishing
    }
    
    open func updateProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
        if progress >= Constants.maxStrokeEndPosition {
            borderLayer.borderColor = crBorderColor.cgColor
        }
    }
    
    lazy var progressPerFrequency: CGFloat = {
        let progressPerSecond = 1.0 / Constants.requestDuration
        return CGFloat(progressPerSecond * Constants.frequencyUpdate)
    }()
    
    // MARK: - Selector && Action
    func touchUpInside(_ sender: SubmitButton) {
        //*Code to reset buton after submit
        guard !isSelected else {
            if currState == .finished {
                resetToReady()
                isSelected = false
            }
            return
        }//*
        
        titleLabel?.font = UIFont.systemFont(ofSize: Constants.minFontSize)
        guard buttonState != .finished else {
            return
        }
        startAnimate()
    }
    
    func touchDownInside(_ sender: SubmitButton) {
        layer.backgroundColor = crDotColor.cgColor
        setTitleColor(UIColor.white, for: UIControlState())
        titleLabel?.font = UIFont.boldSystemFont(ofSize: Constants.maxFontSize)
    }
    
    func touchDragExit(_ sender: SubmitButton) {
        layer.backgroundColor = startBackgroundColor.cgColor
        setTitleColor(startTitleColor, for: UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: Constants.minFontSize)
    }
}


// MARK: - Private Methods
extension SubmitButton {
    
    fileprivate func layoutStartBounds() {
        startBounds = bounds
        borderLayer.bounds = startBounds
        borderLayer.cornerRadius = startBounds.midY
        borderLayer.position = CGPoint(x: startBounds.midX, y: startBounds.midY)
    }
    
    // MARK: Button Setup
    fileprivate func setupCommon() {
        // we should use old swift syntax for pass validation of podspec
        addTarget(self, action: #selector(SubmitButton.touchDownInside(_:)), for: .touchDown)
        addTarget(self, action: #selector(SubmitButton.touchDragExit(_:)), for: .touchDragExit)
        addTarget(self, action: #selector(SubmitButton.touchUpInside(_:)), for: .touchUpInside)
        contentEdgeInsets = UIEdgeInsets(top: 5,left: 20,bottom: 5,right: 20)
        setupButton()
    }
    
    //Function to setup button properties
    fileprivate func setupButton() {
        setTitle(startText, for: UIControlState())
        layer.cornerRadius  = bounds.midY
        layer.borderColor = crBorderColor.cgColor
        layer.addSublayer( borderLayer )
        setTitleColor(startTitleColor, for: UIControlState())
    }
    
    //Function to remove temporary layer
    fileprivate func clearLayerContext() {
        for sublayer in layer.sublayers! {
            if sublayer == borderLayer || sublayer == checkMarkLayer {
                continue
            }
            if sublayer is CAShapeLayer {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    // MARK: Managinf button state
    fileprivate func handleButtonState(_ state: ButtonState) {
        switch state {
        case .ready:
            break
        case .loading:
            isEnabled = false
            prepareLoadingAnimation({
                self.startProgressLoadingAnimation()
            })
        case .finishing:
            finishAnimation()
        case .finished:
            break
        }
    }
    
    
    
    // MARK: Animations Configuring
    
    //add button width animation
    fileprivate func addButtonWidthAnimation(){
        let boundAnim = CABasicAnimation(keyPath: AnimKeys.bounds)
        boundAnim.toValue = NSValue(cgRect: circleBounds)
        
        let colorAnim = CABasicAnimation(keyPath: AnimKeys.backgroundColor)
        colorAnim.toValue = UIColor.white.cgColor
        
        let layerGroup = CAAnimationGroup()
        layerGroup.animations = [boundAnim,colorAnim]
        layerGroup.duration = Constants.prepareLoadingAnimDuration
        layerGroup.delegate = self
        layerGroup.fillMode = kCAFillModeForwards
        layerGroup.isRemovedOnCompletion = false
        layerGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        assignContext(.LoadingStart, anim: layerGroup)
        
        layer.add(layerGroup, forKey: AnimKeys.bounds)
    }
    
    //add button border position and size animation
    fileprivate func addBorderPositionAndSizeDecreasingAnimation(){
        let borderAnim = CABasicAnimation(keyPath: AnimKeys.borderWidth)
        borderAnim.toValue = crLineWidth
        let borderBounds = CABasicAnimation(keyPath: AnimKeys.bounds)
        borderBounds.toValue = NSValue(cgRect: circleBounds)
        let borderPosition = CABasicAnimation(keyPath: AnimKeys.position)
        borderPosition.toValue = NSValue(cgPoint: boundsCenter)
        let borderGroup = CAAnimationGroup()
        borderGroup.animations = [borderAnim,borderBounds,borderPosition]
        borderGroup.duration = Constants.prepareLoadingAnimDuration
        borderGroup.delegate = self
        borderGroup.fillMode = kCAFillModeForwards
        borderGroup.isRemovedOnCompletion = false
        borderGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        assignContext(.LoadingStart, anim: borderGroup)
        borderLayer.add(borderGroup, forKey: nil)
    }
    
    // animate button to loading state, use completion to start loading animation
    fileprivate func prepareLoadingAnimation(_ completion: (()->())?) {
        addButtonWidthAnimation()
        prepareGroup.enter()
        addBorderPositionAndSizeDecreasingAnimation()
        prepareGroup.enter()
        borderLayer.borderColor = UIColor.lightGray.cgColor
        isSelected = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(frequencyOfUpdate), target:self, selector: #selector(SubmitButton.updateLoadingProgress),
                                     userInfo: nil, repeats: true)
        prepareGroup.notify(queue: DispatchQueue.main) {
            self.borderLayer.borderWidth = self.crLineWidth
            self.borderLayer.bounds = self.circleBounds
            self.borderLayer.position = self.boundsCenter
            self.layer.backgroundColor = UIColor.white.cgColor
            self.bounds = self.circleBounds
            self.borderLayer.removeAllAnimations()
            self.layer.removeAllAnimations()
            completion?()
        }
        titleLabel?.layer.opacity = Constants.minOpacity
    }
    
    // start loading animation, that show progress
    fileprivate func startProgressLoadingAnimation() {
        progressLayer.position = boundsCenter
        layer.insertSublayer(progressLayer, above: borderLayer)
    }
    
    // Finishing animation
    fileprivate func finishAnimation() {
        layer.masksToBounds = true
        // lines
        let lines = layer.sublayers!.filter{
            guard $0 != checkMarkLayer && $0 != borderLayer else {
                return false
            }
            return $0 is CAShapeLayer
        }
        // rotation for lines
        let rotation = CABasicAnimation(keyPath: AnimKeys.transform)
        rotation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        rotation.duration = Constants.finishLoadingAnimDuration
        rotation.delegate = self
        assignContext(.LoadingFinishing, anim: rotation)
        for line in lines {
            rotation.fromValue = NSValue(caTransform3D: (line.presentation() as! CAShapeLayer).transform)
            line.add(rotation, forKey: AnimKeys.lineRotation)
            finishLoadingGroup.enter()
        }
        finishLoadingGroup.notify(queue: DispatchQueue.main) {
            self.layer.backgroundColor = self.crDotColor.cgColor
            self.borderLayer.opacity = Constants.maxOpacity
            self.clearLayerContext()
            self.checkMarkAndBoundsAnimation()
        }
    }
    
    //Add button expanding animation
    fileprivate func addButtonPositionAndSizeIncreasingAnimation(){
        let proportions: [CGFloat] = [ circleBounds.width / startBounds.width, 0.9, 1, ]
        var bounces = [NSValue]()
        
        for i in 0..<proportions.count {
            let rect = CGRect(origin: startBounds.origin, size: CGSize(width: startBounds.width * proportions[i], height: startBounds.height))
            bounces.append( NSValue(cgRect: rect) )
        }
        
        let borderBounce = CAKeyframeAnimation(keyPath: AnimKeys.bounds)
        borderBounce.keyTimes = [0 ,0.9,1]
        borderBounce.values = bounces
        borderBounce.duration = Constants.bounceDuration
        borderBounce.beginTime = CACurrentMediaTime() + Constants.resetLinesPositionAnimDuration
        borderBounce.delegate = self
        borderBounce.isRemovedOnCompletion = false
        borderBounce.fillMode = kCAFillModeBoth
        assignContext(.LoadingFinishing, anim: borderBounce)
        borderLayer.add(borderBounce, forKey: nil)
        finishLoadingGroup.enter()
        let borderPosition = CABasicAnimation(keyPath: AnimKeys.position)
        borderPosition.toValue = NSValue(cgPoint: boundsStartCenter)
        borderPosition.duration = Constants.bounceDuration * borderBounce.keyTimes![1].doubleValue
        borderPosition.beginTime = CACurrentMediaTime() + Constants.resetLinesPositionAnimDuration
        borderPosition.delegate = self
        borderPosition.isRemovedOnCompletion = false
        borderPosition.fillMode = kCAFillModeBoth
        assignContext(.LoadingFinishing, anim: borderPosition)
        borderLayer.add(borderPosition, forKey: nil)
        finishLoadingGroup.enter()
        let boundsAnim = CABasicAnimation(keyPath: AnimKeys.bounds)
        boundsAnim.fromValue = NSValue(cgRect: (layer.presentation()!).bounds)
        boundsAnim.toValue = NSValue(cgRect: startBounds)
        let colorAnim = CABasicAnimation(keyPath: AnimKeys.backgroundColor)
        colorAnim.toValue = crDotColor.cgColor
        colorAnim.fromValue = crDotColor.cgColor
        let layerGroup = CAAnimationGroup()
        layerGroup.animations = [boundsAnim, colorAnim]
        layerGroup.duration = Constants.bounceDuration * borderBounce.keyTimes![1].doubleValue
        layerGroup.beginTime = borderBounce.beginTime
        layerGroup.delegate = self
        layerGroup.fillMode = kCAFillModeBoth
        layerGroup.isRemovedOnCompletion = false
        assignContext(.LoadingFinishing, anim: layerGroup)
        layer.add(layerGroup, forKey: AnimKeys.bounds)
        layer.bounds = startBounds
        finishLoadingGroup.enter()
    }
    
    //Add check mark and border expanding animation
    fileprivate func checkMarkAndBoundsAnimation() {
        borderLayer.borderColor = crDotColor.cgColor
        layer.masksToBounds = false
        addButtonPositionAndSizeIncreasingAnimation()
        //Adding tick mark
        checkMarkLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        if checkMarkLayer.superlayer == nil {
            checkMarkLayer.path = pathForMark().cgPath
            layer.addSublayer( checkMarkLayer )
        }
        finishLoadingGroup.notify(queue: DispatchQueue.main) {
            UIView.animate(withDuration: 1.5, animations: {
                self.checkMarkLayer.opacity = Constants.maxOpacity
            })
            self.buttonState = .finished
            self.isEnabled = true
        }
    }
    
    // MARK: Check mark
    
    // Configuring check mark layer
    fileprivate func createMarkLayer() -> CAShapeLayer {
        // configure layer
        let layer         = CAShapeLayer()
        layer.bounds      = circleBounds
        layer.opacity     = Constants.minOpacity
        layer.fillColor   = nil
        layer.strokeColor = UIColor.white.cgColor
        layer.lineCap     = kCALineCapRound
        layer.lineJoin    = kCALineJoinRound
        layer.lineWidth   = crLineWidth
        
        return layer
    }
    
    //Function for creating the check mark layer
    fileprivate func createCheckMark() -> CAShapeLayer {
        let checkmarkLayer = createMarkLayer()
        return checkmarkLayer
    }
    
    //Function for drawing the check mark
    fileprivate func pathForMark() -> UIBezierPath {
        // geometry of the layer
        let percentShiftY:CGFloat = 0.4
        let percentShiftX:CGFloat = -0.2
        
        let firstRadius = 0.5 * circleBounds.midY
        let lastRadius  = 1 * circleBounds.midY
        
        let firstAngle  = CGFloat(-3 * M_PI_4)
        let lastAngle   = CGFloat(-1 * M_PI_4)
        
        var startPoint  = CGPoint(x: firstRadius * cos(firstAngle), y: firstRadius * sin(firstAngle))
        var midPoint    = CGPoint.zero
        var endPoint    = CGPoint(x: lastRadius * cos(lastAngle), y: lastRadius * sin(lastAngle))
        
        let correctedPoint = CGPoint(x: boundsCenter.x + (boundsCenter.x * percentShiftX),
                                     y: boundsCenter.y + (boundsCenter.y * percentShiftY))
        
        startPoint.addPoint( correctedPoint )
        midPoint.addPoint( correctedPoint )
        endPoint.addPoint( correctedPoint )
        
        let path = UIBezierPath()
        path.move( to: startPoint )
        path.addLine( to: midPoint )
        path.addLine( to: endPoint )
        return path
    }
    
    fileprivate func assignContext(_ context:AnimContext, anim: CAAnimation ) {
        anim.setValue(context.rawValue, forKey: Constants.contextID)
    }
    fileprivate func assignLayer(_ aLayer: CALayer, anim: CAAnimation) {
        anim.setValue(aLayer, forKey: Constants.layerAnimation)
    }
}

// MARK: - Animation Delegate
extension SubmitButton : CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }
        guard let contextRawValue = anim.value( forKey: Constants.contextID ) as? String else {
            return
        }
        let context = AnimContext(rawValue: contextRawValue)!
        switch context {
        case .LoadingStart:
            prepareGroup.leave()
        case .LoadingFinishing:
            finishLoadingGroup.leave()
        }
    }
}


//MARK: CGPoint customization
extension CGPoint {
    fileprivate mutating func addPoint(_ point: CGPoint) {
        x += point.x
        y += point.y
    }
}


