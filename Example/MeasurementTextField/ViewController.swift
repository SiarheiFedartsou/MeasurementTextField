//
//  ViewController.swift
//  MeasurementTextField
//
//  Created by SiarheiFedartsou on 01/13/2018.
//  Copyright (c) 2018 SiarheiFedartsou. All rights reserved.
//

import UIKit
import MeasurementTextField

class ViewController: UIViewController {

    private let heightTextField1 = MeasurementTextField.forBodyHeight(locale: Locale(identifier: "de_DE"))
    private let heightTextField2 = MeasurementTextField.forBodyHeight(locale: Locale(identifier: "en_US"))
    
    private let weightTextField1 = MeasurementTextField.forBodyWeight(locale: Locale(identifier: "de_DE"))
    private let weightTextField2 = MeasurementTextField.forBodyWeight(locale: Locale(identifier: "en_US"))
    
    private let angleTextField = MeasurementTextField<UnitAngle>(inputType: .picker([
        PickerColumn(unit: UnitAngle.degrees, range: 0...360),
        PickerColumn(unit: UnitAngle.arcMinutes, range: 0...60),
        PickerColumn(unit: UnitAngle.arcSeconds, range: 0...60),
    ]))
    
    private func log<T: Dimension>(_ value: Measurement<T>?) {
        if let value = value {
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            formatter.unitStyle = .long
            print(formatter.string(from: value))
        } else {
            print("nil")
        }
    }
    
    @objc private func onHeight1ValueChanged() {
        log(heightTextField1.value)
    }
    
    @objc private func onHeight2ValueChanged() {
        log(heightTextField2.value)
    }
    
    @objc private func onWeight1ValueChanged() {
        log(weightTextField1.value)
    }
    
    @objc private func onWeight2ValueChanged() {
        log(weightTextField2.value)
    }
    
    @objc private func onAngleValueChanged() {
        log(angleTextField.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(heightTextField1)
        view.addSubview(heightTextField2)
        view.addSubview(weightTextField1)
        view.addSubview(weightTextField2)
        view.addSubview(angleTextField)
        
        heightTextField1.delegate = self
        heightTextField2.delegate = self
        weightTextField1.delegate = self
        weightTextField2.delegate = self
        angleTextField.delegate = self

        heightTextField1.value = Measurement(value: 1.5, unit: .meters)
        heightTextField1.tintColor = .red
        heightTextField1.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        heightTextField2.value = Measurement(value: 1.6, unit: .meters)

        heightTextField1.borderStyle = .roundedRect
        weightTextField1.borderStyle = .roundedRect
        weightTextField2.borderStyle = .roundedRect
        weightTextField2.placeholder = "Weight"
        
        angleTextField.placeholder = "Angle"
        angleTextField.value = Measurement(value: 150.5, unit: .degrees)
        
        heightTextField1.addTarget(self, action: #selector(onHeight1ValueChanged), for: .valueChanged)
        heightTextField2.addTarget(self, action: #selector(onHeight2ValueChanged), for: .valueChanged)
        weightTextField1.addTarget(self, action: #selector(onWeight1ValueChanged), for: .valueChanged)
        weightTextField2.addTarget(self, action: #selector(onWeight2ValueChanged), for: .valueChanged)
        angleTextField.addTarget(self, action: #selector(onAngleValueChanged), for: .valueChanged)
        
        heightTextField1.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightTextField1.frame = CGRect(x: 40, y: 40, width: UIScreen.main.bounds.width - 80, height: 44)
        heightTextField2.frame = CGRect(x: 40, y: 100, width: UIScreen.main.bounds.width - 80, height: 44)
        weightTextField1.frame = CGRect(x: 40, y: 160, width: UIScreen.main.bounds.width - 80, height: 44)
        weightTextField2.frame = CGRect(x: 40, y: 220, width: UIScreen.main.bounds.width - 80, height: 44)
        angleTextField.frame = CGRect(x: 40, y: 280, width: UIScreen.main.bounds.width - 80, height: 44)
    }

}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
