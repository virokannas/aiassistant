//
//  BubbleView.swift
//  AIAssistant
//
//  Created by Simo Virokannas on 5/10/21.
//

import Foundation

import UIKit

class BubbleView : UIView {
    enum Side: Int {
        case left = 1
        case right = 2
    }
    
    var side : BubbleView.Side = .left
    var empty : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        if self.empty {
            return
        }
        let width = rect.width
        let height = rect.height
        if side == .left {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 22, y: height))
            bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
            bezierPath.addLine(to: CGPoint(x: width, y: 17))
            bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
            bezierPath.addLine(to: CGPoint(x: 21, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
            bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
            bezierPath.addCurve(to: CGPoint(x: 11.04, y: height - 4.04), controlPoint1: CGPoint(x: 4.07, y: height + 0.43), controlPoint2: CGPoint(x: 8.16, y: height - 1.06))
            bezierPath.addCurve(to: CGPoint(x: 22, y: height), controlPoint1: CGPoint(x: 16, y: height), controlPoint2: CGPoint(x: 19, y: height))
            bezierPath.close()
            UIColor.systemGray2.setFill()
            bezierPath.fill()
        } else {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: width - 22, y: height))
            bezierPath.addLine(to: CGPoint(x: 17, y: height))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height - 17), controlPoint1: CGPoint(x: 7.61, y: height), controlPoint2: CGPoint(x: 0, y: height - 7.61))
            bezierPath.addLine(to: CGPoint(x: 0, y: 17))
            bezierPath.addCurve(to: CGPoint(x: 17, y: 0), controlPoint1: CGPoint(x: 0, y: 7.61), controlPoint2: CGPoint(x: 7.61, y: 0))
            bezierPath.addLine(to: CGPoint(x: width - 21, y: 0))
            bezierPath.addCurve(to: CGPoint(x: width - 4, y: 17), controlPoint1: CGPoint(x: width - 11.61, y: 0), controlPoint2: CGPoint(x: width - 4, y: 7.61))
            bezierPath.addLine(to: CGPoint(x: width - 4, y: height - 11))
            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 4, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
            bezierPath.addCurve(to: CGPoint(x: width - 11.04, y: height - 4.04), controlPoint1: CGPoint(x: width - 4.07, y: height + 0.43), controlPoint2: CGPoint(x: width - 8.16, y: height - 1.06))
            bezierPath.addCurve(to: CGPoint(x: width - 22, y: height), controlPoint1: CGPoint(x: width - 16, y: height), controlPoint2: CGPoint(x: width - 19, y: height))
            bezierPath.close()
            UIColor.systemBlue.setFill()
            bezierPath.fill()
        }
        super.draw(rect)
    }
}

class BubbleCell : UICollectionViewCell{
    var chatMessage: AIMessage? {
        didSet{
            setupCell()
        }
    }
        
    private let chatLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.textAlignment = .left
        l.textColor = .white
        l.font = .systemFont(ofSize: 16.0, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let bubbleView: BubbleView = {
        let bv = BubbleView()
        bv.translatesAutoresizingMaskIntoConstraints = false
        return bv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        setupUI()
    }
    
    var lc : NSLayoutConstraint? = nil
    var tc : NSLayoutConstraint? = nil
    var lc2 : NSLayoutConstraint? = nil
    var tc2 : NSLayoutConstraint? = nil

    private func setupUI(){
        addSubview(bubbleView)
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        lc = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        lc!.isActive = true
        tc = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        tc!.isActive = true
        
        bubbleView.addSubview(chatLabel)
        chatLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0).isActive = true
        lc2 = chatLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0)
        lc2!.isActive = true
        tc2 = chatLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0)
        tc2!.isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: chatLabel.bottomAnchor, constant: 8.0).isActive = true
    }
    
    private func setupCell(){
        guard let chatMessage = chatMessage else { return }
        chatLabel.text = chatMessage.text
        if chatMessage.me {
            bubbleView.side = .right
            lc!.constant = 100
            tc!.constant = -10
            lc2!.constant = 120
            tc2!.constant = -30
        } else {
            bubbleView.side = .left
            lc!.constant = 10
            tc!.constant = -100
            lc2!.constant = 30
            tc2!.constant = -120
        }
        if chatMessage.empty {
            bubbleView.empty = true
        } else {
            bubbleView.empty = false
        }
        bubbleView.setNeedsDisplay()
        chatLabel.setNeedsLayout()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
