//
//  Extensions.swift
//  AIAssistant
//
//  Created by Simo Virokannas on 5/10/21.
//

import UIKit

// Traceable: https://stackoverflow.com/a/44881985

protocol Traceable {
    var cornerRadius: CGFloat { get set }
    var borderColor: UIColor? { get set }
    var borderWidth: CGFloat { get set }
}

extension UIView: Traceable {

    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return  UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
}

extension UITextView {
    func scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
    }
}

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        let y = contentSize.height - 1
        let rect = CGRect(x: 0, y: y + safeAreaInsets.bottom, width: 1, height: 1)
        scrollRectToVisible(rect, animated: animated)
    }
}
