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

public enum ButtonLoadingType {
    case continuous
    case timeLimited
}

public enum ButtonCompletionStatus {
    case success
    case canceled
    case failed
}

private struct Constants {
    static let contextID   = "kAnimationIdentifier"
    static let layerAnimation = "kLayerAnimation"
    static let cancelButtonTitle = "Cancelled"
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
    static let borderBounceKeyTime: [NSNumber] = [0, 0.9, 1]
    static let errorCrossMarkXShift: CGFloat = 15
    static let errorCrossMarkYShift: CGFloat = 15
    static let cancelButtonTag: Int = 100
    static let cancelMarkXShift: CGFloat = 17
    static let cancelMarkYShift: CGFloat = 17
    static let cancelButtonHeight: CGFloat = 40
    static let cancelButtonWidth: CGFloat = 40
}

private struct AnimKeys {
    static let bounds = "bounds"
    static let backgroundColor = "backgroundColor"
    static let position = "position"
    static let lineRotation = "lineRotation"
    static let transform = "transform"
    static let borderWidth = "borderWidth"
    static let opacity = "opacity"
    static let transformRotationZ = "transform.rotation.z"
}

enum AnimContext: String {
    case LoadingStart
    case LoadingFinishing
}

public typealias CompletionType = (SubmitButton) -> Void

@IBDesignable
open class SubmitButton: UIButton {
    // MARK: - Public variables
    /// Button loading type
    open var loadingType: ButtonLoadingType  = ButtonLoadingType.timeLimited
    /// Color of dots and line in loading state
    @IBInspectable open var sbDotColor: UIColor = #colorLiteral(red: 0, green: 0.8250309825, blue: 0.6502585411, alpha: 1)
    /// Color of error button
    @IBInspectable open var errorColor: UIColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    /// Color of cancelled button state
    @IBInspectable open var cancelledButtonColor: UIColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    /// Line width of the border
    @IBInspectable open var sbLineWidth: CGFloat = 3
    /// Border Color
    @IBInspectable open var sbBorderColor: UIColor = #colorLiteral(red: 0, green: 0.8250309825, blue: 0.6502585411, alpha: 1) {
        didSet {
            borderLayer.borderColor = sbBorderColor.cgColor
        }
    }
    /// Lines count on loading state
    open var linesCount: UInt = 2
    /// Measure in radians
    @IBInspectable open var dotLength: CGFloat = 0.1
    /// Time for pass one lap
    @IBInspectable open var velocity: Double = 2
    /// Loading center Color
    @IBInspectable open var loadingCenterColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    /// Button background color
    @IBInspectable open var startBackgroundColor: UIColor! = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            layer.backgroundColor = startBackgroundColor.cgColor
        }
    }
    /// Button title color
    @IBInspectable open var startTitleColor: UIColor! = #colorLiteral(red: 0, green: 0.8250309825, blue: 0.6502585411, alpha: 1) {
        didSet {
            setTitleColor(startTitleColor, for: UIControlState())
        }
    }
    /// Show cancel option while loading
    @IBInspectable open var cancelEnabled: Bool = false
    /// Color of error button
    @IBInspectable open var cancelOptionColor: UIColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    @IBInspectable open var startText: String = "Submit" {
        didSet {
            setTitle(startText, for: UIControlState())
        }
    }
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
        layer.borderColor = self.sbBorderColor.cgColor
        layer.backgroundColor = nil
        return layer
    }()
    fileprivate lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = self.sbDotColor.cgColor
        layer.bounds = self.circleBounds
        layer.path = UIBezierPath(arcCenter: self.boundsCenter, radius: self.boundsCenter.y - self.sbLineWidth / 2,
                                  startAngle: CGFloat(-M_PI_2), endAngle: 3*CGFloat(M_PI_2), clockwise: true).cgPath
        layer.strokeEnd = Constants.minStrokeEndPosition
        layer.lineCap = kCALineCapRound
        layer.lineWidth = self.sbLineWidth
        return layer
    }()
    fileprivate lazy var checkMarkLayer: CAShapeLayer = {
        return self.createCheckMark()
    }()
    fileprivate lazy var errorCrossMarkLayer: CAShapeLayer = {
        return self.createErrorCrossMark()
    }()
    fileprivate lazy var cancelLayer: CAShapeLayer = {
        return self.createCancel()
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
    fileprivate var isCancelEnabled: Bool = false
    // Constraints for button
    fileprivate var conWidth: NSLayoutConstraint!
    fileprivate var conHeight: NSLayoutConstraint!
    fileprivate var startBounds: CGRect!
    fileprivate let prepareGroup = DispatchGroup()
    fileprivate let finishLoadingGroup = DispatchGroup()
    fileprivate var progress: CGFloat = 0
    fileprivate var timer: Timer?
    fileprivate var taskCompletion: CompletionType?
    //intiate the update of the progress of progress bar
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
    //Function to reset button view
    open func resetToReady() {
        progress = 0
        isCancelEnabled = false
        buttonState = .ready
        borderLayer.removeAllAnimations()
        layer.removeAllAnimations()
        checkMarkLayer.removeAllAnimations()
        errorCrossMarkLayer.removeAllAnimations()
        clearLayerContext()
        CATransaction.begin()
        CATransaction.setDisableActions( true )
        layer.backgroundColor = startBackgroundColor.cgColor
        checkMarkLayer.opacity = Constants.minOpacity
        errorCrossMarkLayer.opacity = Constants.minOpacity
        borderLayer.borderWidth = Constants.borderWidth
        borderLayer.borderColor = sbBorderColor.cgColor
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
    // update of the progress of progress bar
    open func updateProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
    open func taskCompletion(completion: @escaping CompletionType) {
        taskCompletion = completion
    }
    lazy var progressPerFrequency: CGFloat = {
        let progressPerSecond = 1.0 / Constants.requestDuration
        return CGFloat(progressPerSecond * Constants.frequencyUpdate)
    }()
    // MARK: - Selector && Action
    func touchUpInside(_ sender: SubmitButton) {
        if self.buttonState != .loading {
            //*Code to reset buton after submit, comment these if not needed
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
        addTarget(self, action: #selector(SubmitButton.touchUpInside(_:)), for: .touchUpInside)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        setupButton()
    }
    //Function to setup button properties
    fileprivate func setupButton() {
        setTitle(startText, for: UIControlState())
        layer.cornerRadius  = bounds.midY
        layer.borderColor = sbBorderColor.cgColor
        layer.addSublayer( borderLayer )
        setTitleColor(startTitleColor, for: UIControlState())
    }
    //Function to remove temporary layer
    fileprivate func clearLayerContext() {
        for sublayer in layer.sublayers! {
            if sublayer == borderLayer || sublayer == checkMarkLayer || sublayer == errorCrossMarkLayer {
                continue
            }
            if sublayer is CAShapeLayer {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    // MARK: Managing button state
    fileprivate func handleButtonState(_ state: ButtonState) {
        switch state {
        case .ready:
            break
        case .loading:
            prepareLoadingAnimation({
                if self.loadingType == ButtonLoadingType.timeLimited {
                    self.startProgressLoadingAnimation()
                } else {
                    self.startLoadingAnimation()
                }
            })
        case .finishing:
            finishAnimation()
        case .finished:
            break
        }
    }
    // MARK: Animations Configuring
    //add button width animation
    fileprivate func addButtonWidthAnimation() {
        let boundAnim = CABasicAnimation(keyPath: AnimKeys.bounds)
        boundAnim.toValue = NSValue(cgRect: circleBounds)
        let colorAnim = CABasicAnimation(keyPath: AnimKeys.backgroundColor)
        colorAnim.toValue = startTitleColor.cgColor
        let layerGroup = CAAnimationGroup()
        layerGroup.animations = [boundAnim, colorAnim]
        layerGroup.duration = Constants.prepareLoadingAnimDuration
        layerGroup.delegate = self
        layerGroup.fillMode = kCAFillModeForwards
        layerGroup.isRemovedOnCompletion = false
        layerGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        assignContext(.LoadingStart, anim: layerGroup)
        layer.add(layerGroup, forKey: AnimKeys.bounds)
    }
    //add button border position and size animation
    fileprivate func addBorderPositionAndSizeDecreasingAnimation() {
        let borderAnim = CABasicAnimation(keyPath: AnimKeys.borderWidth)
        borderAnim.toValue = sbLineWidth
        let borderBounds = CABasicAnimation(keyPath: AnimKeys.bounds)
        borderBounds.toValue = NSValue(cgRect: circleBounds)
        let borderPosition = CABasicAnimation(keyPath: AnimKeys.position)
        borderPosition.toValue = NSValue(cgPoint: boundsCenter)
        let borderGroup = CAAnimationGroup()
        borderGroup.animations = [borderAnim, borderBounds, borderPosition]
        borderGroup.duration = Constants.prepareLoadingAnimDuration
        borderGroup.delegate = self
        borderGroup.fillMode = kCAFillModeForwards
        borderGroup.isRemovedOnCompletion = false
        borderGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        assignContext(.LoadingStart, anim: borderGroup)
        borderLayer.add(borderGroup, forKey: nil)
    }
    // For adding time for loading
    fileprivate func addTimerForLimitedTimeLoadingAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(frequencyOfUpdate), target:self,
                                     selector: #selector(SubmitButton.updateLoadingProgress),
                                     userInfo: nil, repeats: true)
    }
    // animate button to loading state, use completion to start loading animation
    fileprivate func prepareLoadingAnimation(_ completion: (() -> Void)?) {
        addButtonWidthAnimation()
        prepareGroup.enter()
        addBorderPositionAndSizeDecreasingAnimation()
        prepareGroup.enter()
        borderLayer.borderColor = UIColor.lightGray.cgColor
        isSelected = true
        if self.loadingType == ButtonLoadingType.timeLimited {
            addTimerForLimitedTimeLoadingAnimation()
        }
        prepareGroup.notify(queue: DispatchQueue.main) {
            self.borderLayer.borderWidth = self.sbLineWidth
            self.borderLayer.bounds = self.circleBounds
            self.borderLayer.position = self.boundsCenter
            self.layer.backgroundColor = self.loadingCenterColor.cgColor
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
        if cancelEnabled {
            addCancelOptionWhileLoading()
        }
    }
    // start default loading
    fileprivate func startLoadingAnimation() {
        let arCenter = boundsCenter
        let radius   = circleBounds.midX - sbLineWidth / 2
        var lines = [CAShapeLayer]()
        let lineOffset: CGFloat = 2 * CGFloat(M_PI) / CGFloat(linesCount)
        for i in 0..<linesCount {
            let line = CAShapeLayer()
            let startAngle = lineOffset * CGFloat(i)
            line.path = UIBezierPath(arcCenter: arCenter,
                                     radius: radius,
                                     startAngle: startAngle,
                                     endAngle: startAngle + dotLength,
                                     clockwise: true).cgPath
            line.bounds = circleBounds
            line.strokeColor = sbDotColor.cgColor
            line.lineWidth = sbLineWidth
            line.fillColor = sbDotColor.cgColor
            line.lineCap = kCALineCapRound
            layer.insertSublayer(line, above: borderLayer)
            line.position = arCenter
            lines.append( line )
        }
        let opacityAnim = CABasicAnimation(keyPath: AnimKeys.opacity)
        opacityAnim.fromValue = 0
        let rotation = CABasicAnimation(keyPath: AnimKeys.transformRotationZ)
        rotation.byValue = NSNumber(value: 2*M_PI as Double)
        rotation.duration = velocity
        rotation.repeatCount = Float.infinity
        for line in lines {
            line.add(rotation, forKey: AnimKeys.lineRotation)
            line.add(opacityAnim, forKey: nil)
        }
        if cancelEnabled {
            addCancelOptionWhileLoading()
        }
    }
    // Finishing animation
    fileprivate func finishAnimation() {
        layer.masksToBounds = true
        // lines
        let lines = layer.sublayers!.filter {
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
            rotation.fromValue = NSValue(caTransform3D: ((line.presentation() as? CAShapeLayer)?.transform)!)
            line.add(rotation, forKey: AnimKeys.lineRotation)
            finishLoadingGroup.enter()
        }
        finishLoadingGroup.notify(queue: DispatchQueue.main) {
            self.taskCompletion!(self)
        }
    }
    //Complete animation based on user input
    open func completeAnimation(status: ButtonCompletionStatus) {
        if cancelEnabled && isCancelEnabled && status != .canceled {
            return
        }
        timer?.invalidate()
        viewWithTag(Constants.cancelButtonTag)?.removeFromSuperview()
        self.checkMarkAndBoundsAnimation(completionStatus: status)
        self.clearLayerContext()
    }
    //Add button border expanding
    fileprivate func addButtonBorderIncreasingAnimation() {
        let proportions: [CGFloat] = [ circleBounds.width / startBounds.width, 0.9, 1]
        var bounces = [NSValue]()
        for i in 0..<proportions.count {
            let rect = CGRect(origin: startBounds.origin, size: CGSize(width: startBounds.width * proportions[i],
                                                                       height: startBounds.height))
            bounces.append( NSValue(cgRect: rect) )
        }
        let borderBounce = CAKeyframeAnimation(keyPath: AnimKeys.bounds)
        borderBounce.keyTimes = Constants.borderBounceKeyTime
        borderBounce.values = bounces
        borderBounce.duration = Constants.bounceDuration
        borderBounce.beginTime = CACurrentMediaTime() + Constants.resetLinesPositionAnimDuration
        borderBounce.delegate = self
        borderBounce.isRemovedOnCompletion = false
        borderBounce.fillMode = kCAFillModeBoth
        assignContext(.LoadingFinishing, anim: borderBounce)
        borderLayer.add(borderBounce, forKey: nil)
        finishLoadingGroup.enter()
    }
    //Add button border position animation
    fileprivate func addButtonBorderPositionUpdationAnimation() {
        let borderPosition = CABasicAnimation(keyPath: AnimKeys.position)
        borderPosition.toValue = NSValue(cgPoint: boundsStartCenter)
        borderPosition.duration = Constants.bounceDuration * Constants.borderBounceKeyTime[1].doubleValue
        borderPosition.beginTime = CACurrentMediaTime() + Constants.resetLinesPositionAnimDuration
        borderPosition.delegate = self
        borderPosition.isRemovedOnCompletion = false
        borderPosition.fillMode = kCAFillModeBoth
        assignContext(.LoadingFinishing, anim: borderPosition)
        borderLayer.add(borderPosition, forKey: nil)
        finishLoadingGroup.enter()
    }
    //Add button bound animation
    fileprivate func addButtonBoundsAnimation(completionStatus: ButtonCompletionStatus) {
        let boundsAnim = CABasicAnimation(keyPath: AnimKeys.bounds)
        boundsAnim.fromValue = NSValue(cgRect: (layer.presentation()!).bounds)
        boundsAnim.toValue = NSValue(cgRect: startBounds)
        let colorAnim = CABasicAnimation(keyPath: AnimKeys.backgroundColor)
        if completionStatus == .success {
            colorAnim.toValue = sbDotColor.cgColor
            colorAnim.fromValue = sbDotColor.cgColor
        } else if completionStatus == .failed {
            colorAnim.toValue = errorColor.cgColor
            colorAnim.fromValue = errorColor.cgColor
        } else {
            colorAnim.toValue = cancelledButtonColor.cgColor
            colorAnim.fromValue = cancelledButtonColor.cgColor
        }
        let layerGroup = CAAnimationGroup()
        layerGroup.animations = [boundsAnim, colorAnim]
        layerGroup.duration = Constants.bounceDuration * Constants.borderBounceKeyTime[1].doubleValue
        layerGroup.beginTime = CACurrentMediaTime() + Constants.resetLinesPositionAnimDuration
        layerGroup.delegate = self
        layerGroup.fillMode = kCAFillModeBoth
        layerGroup.isRemovedOnCompletion = false
        assignContext(.LoadingFinishing, anim: layerGroup)
        layer.add(layerGroup, forKey: AnimKeys.bounds)
        layer.bounds = startBounds
        finishLoadingGroup.enter()
    }
    //Add button expanding animation
    fileprivate func addButtonPositionAndSizeIncreasingAnimation(status: ButtonCompletionStatus) {
        addButtonBorderIncreasingAnimation()
        addButtonBorderPositionUpdationAnimation()
        addButtonBoundsAnimation(completionStatus: status)
    }
    //Add check mark and border expanding animation
    fileprivate func checkMarkAndBoundsAnimation(completionStatus: ButtonCompletionStatus) {
        self.borderLayer.opacity = Constants.maxOpacity
        layer.masksToBounds = false
        addButtonPositionAndSizeIncreasingAnimation(status: completionStatus)
        if completionStatus == .success {
            //Adding tick mark
            self.layer.backgroundColor = self.sbDotColor.cgColor
            borderLayer.borderColor = sbDotColor.cgColor
            checkMarkLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
            if checkMarkLayer.superlayer == nil {
                checkMarkLayer.path = pathForMark().cgPath
                layer.addSublayer( checkMarkLayer )
            }
        } else if completionStatus == .failed {
            self.layer.backgroundColor = errorColor.cgColor
            borderLayer.borderColor = errorColor.cgColor
            errorCrossMarkLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
            if errorCrossMarkLayer.superlayer == nil {
                errorCrossMarkLayer.path = pathForCrossMark(XShift: Constants.errorCrossMarkXShift,
                                                            YShift: Constants.errorCrossMarkYShift).cgPath
                layer.addSublayer( errorCrossMarkLayer )
            }
        } else {
            self.layer.backgroundColor = cancelledButtonColor.cgColor
            borderLayer.borderColor = cancelledButtonColor.cgColor
            setTitle(Constants.cancelButtonTitle, for: UIControlState())
            setTitleColor(UIColor.white, for: UIControlState())
        }
        finishLoadingGroup.notify(queue: DispatchQueue.main) {
            UIView.animate(withDuration: 0.5, animations: {
                if completionStatus == .success {
                    self.checkMarkLayer.opacity = Constants.maxOpacity
                } else if completionStatus == .failed {
                    self.errorCrossMarkLayer.opacity = Constants.maxOpacity
                } else {
                    self.titleLabel?.alpha = CGFloat(Constants.maxOpacity)
                }
            })
            self.buttonState = .finished
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
        layer.strokeColor = startBackgroundColor.cgColor
        layer.lineCap     = kCALineCapRound
        layer.lineJoin    = kCALineJoinRound
        layer.lineWidth   = sbLineWidth
        return layer
    }
    //Function for creating the check mark layer
    fileprivate func createCheckMark() -> CAShapeLayer {
        let checkmarkLayer = createMarkLayer()
        return checkmarkLayer
    }
    fileprivate func createErrorCrossMark() -> CAShapeLayer {
        let crossmarkLayer = createMarkLayer()
        return crossmarkLayer
    }
    fileprivate func createCancel() -> CAShapeLayer {
        let cancelLayer = createMarkLayer()
        return cancelLayer
    }
    //Function for drawing the check mark
    fileprivate func pathForMark() -> UIBezierPath {
        // geometry of the layer
        let percentShiftY: CGFloat = 0.4
        let percentShiftX: CGFloat = -0.2
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
    fileprivate func pathForCrossMark(XShift: CGFloat, YShift: CGFloat) -> UIBezierPath {
        // geometry for crossmark layer
        let firstStartPoint  = CGPoint(x: XShift, y: YShift)
        let firstEndPoint    = CGPoint(x: circleBounds.maxX - XShift, y: circleBounds.maxY - XShift)
        let secondStartPoint = CGPoint(x: circleBounds.maxX - XShift, y: circleBounds.minY + YShift)
        let secondEndPoint   = CGPoint(x: circleBounds.minX + XShift, y: circleBounds.maxY - YShift)
        let path = UIBezierPath()
        path.move(to: firstStartPoint)
        path.addLine(to: firstEndPoint)
        path.move(to: secondStartPoint)
        path.addLine(to: secondEndPoint)
        return path
    }
    fileprivate func addCancelOptionWhileLoading() {
        let button = UIButton(type: .custom)
        button.tag = Constants.cancelButtonTag
        button.frame = CGRect(x: layer.bounds.midX-Constants.cancelButtonWidth/2,
                              y: layer.bounds.midY-Constants.cancelButtonHeight/2,
                              width: Constants.cancelButtonWidth,
                              height: Constants.cancelButtonHeight)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        let tempLayer         = CAShapeLayer()
        tempLayer.bounds      = button.frame
        tempLayer.fillColor   = nil
        tempLayer.strokeColor = cancelOptionColor.cgColor
        tempLayer.lineCap     = kCALineCapRound
        tempLayer.lineJoin    = kCALineJoinRound
        tempLayer.lineWidth   = sbLineWidth
        tempLayer.position = CGPoint(x: button.layer.bounds.midX, y: button.layer.bounds.midY)
        tempLayer.path = pathForCrossMark(XShift: Constants.cancelMarkXShift, YShift: Constants.cancelMarkYShift).cgPath
        button.layer.addSublayer( tempLayer )
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        self.addSubview(button)
    }
    func cancelButtonPressed() {
        isCancelEnabled = true
        completeAnimation(status: .canceled)
    }
    fileprivate func assignContext(_ context: AnimContext, anim: CAAnimation ) {
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
// MARK: CGPoint customization
extension CGPoint {
    fileprivate mutating func addPoint(_ point: CGPoint) {
        x += point.x
        y += point.y
    }
}
