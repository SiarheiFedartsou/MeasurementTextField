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

    private let heightTextField1 = MeasurementTextField<UnitLength>(inputType: .keyboard(.centimeters, showMeasureUnit: true))
    private let heightTextField2 = MeasurementTextField<UnitLength>(inputType: .picker([
        PickerColumn(unit: UnitLength.feet, range: 0...9),
        PickerColumn(unit: UnitLength.inches, range: 0...11)
        ]))
    
    private let weightTextField1 = MeasurementTextField<UnitMass>(inputType: .keyboard(.kilograms, showMeasureUnit: false))
    private let weightTextField2 = MeasurementTextField<UnitMass>(inputType: .picker([
        PickerColumn(unit: UnitMass.kilograms, range: 60...120),
        PickerColumn(unit: UnitMass.grams, range: 0...1000, step: 100)
    ]))
    
    private func onValueChanged<T: Dimension>(_ value: Measurement<T>?) {
        if let value = value {
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            formatter.unitStyle = .long
            print(formatter.string(from: value))
        } else {
            print("nil")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(heightTextField1)
        view.addSubview(heightTextField2)
        view.addSubview(weightTextField1)
        view.addSubview(weightTextField2)
        
        heightTextField1.onValueChanged = self.onValueChanged
        heightTextField2.onValueChanged = self.onValueChanged
        weightTextField1.onValueChanged = self.onValueChanged
        weightTextField2.onValueChanged = self.onValueChanged
        
        heightTextField1.value = Measurement(value: 1.5, unit: .meters)
        heightTextField2.value = Measurement(value: 1.6, unit: .meters)
        
        heightTextField1.textField.borderStyle = .roundedRect
        weightTextField1.textField.borderStyle = .roundedRect
        weightTextField2.textField.borderStyle = .roundedRect
        weightTextField2.textField.placeholder = "Weight"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightTextField1.frame = CGRect(x: 40, y: 40, width: UIScreen.main.bounds.width - 80, height: 44)
        heightTextField2.frame = CGRect(x: 40, y: 100, width: UIScreen.main.bounds.width - 80, height: 44)
        weightTextField1.frame = CGRect(x: 40, y: 160, width: UIScreen.main.bounds.width - 80, height: 44)
        weightTextField2.frame = CGRect(x: 40, y: 220, width: UIScreen.main.bounds.width - 80, height: 44)
    }

}

