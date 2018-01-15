//
//  TextField.swift
//  MeasurementTextField
//
//  Created by Siarhei Fedartsou on 1/14/18.
//

import UIKit

internal final class TextField: UITextField {
    var showCaret: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return showCaret ? super.caretRect(for: position) : .zero
    }
}
