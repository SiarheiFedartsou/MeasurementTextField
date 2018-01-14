//
//  MeasurementTextField.swift
//  MeasurementTextField
//
//  Created by Siarhei Fedartsou on 1/13/18.
//

import UIKit


private enum Layout {
    static let measureUnitLabelRightInset: CGFloat = 10.0
}

public final class MeasurementTextField<UnitType: Dimension>: UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    public var textField: UITextField {
        return internalTextField
    }
    
    private lazy var internalTextField: TextField = {
        let textField = TextField()
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
        return textField
    }()
    
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        return pickerView
    }()
    
    private let inputType: InputType<UnitType>
    
    public init(inputType: InputType<UnitType>) {
        #if DEBUG
            if case let .picker(columns) = inputType {
                var lastValue = Double.greatestFiniteMagnitude
                for column in columns {
                    let value = Measurement(value: 1.0, unit: column.unit).converted(to: UnitType.baseUnit()).value
                    assert(value < lastValue, "Columns should be ordered from largest to smallest units")
                    lastValue = value
                }
            }
        #endif
        
        self.inputType = inputType
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(internalTextField)
        
        switch inputType {
        case let .keyboardInput(unit, showMeasureUnit):
            guard showMeasureUnit else { return }
            let unitLabel = UILabel()
            unitLabel.text = unit.symbol
            unitLabel.sizeToFit()
            unitLabel.frame.size.width += Layout.measureUnitLabelRightInset
            internalTextField.rightView = unitLabel
            internalTextField.rightViewMode = .always
        case .picker:
            internalTextField.inputView = pickerView
            internalTextField.showCaret = false
            internalTextField.clearButtonMode = .whileEditing
        }
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        internalTextField.frame = bounds
    }
    
    
    public var onValueChanged: (Measurement<UnitType>?) -> Void = { _ in }
    
    public var value: Measurement<UnitType>? {
        set {
            internalValue = newValue
            
            switch inputType {
            case let .keyboardInput(unit, _):
                guard let value = value else {
                    internalTextField.text = ""
                    return
                }
                let convertedValue = value.converted(to: unit)
                internalTextField.text = stringFromDouble(convertedValue.value)
            case let .picker(columns):
                setPicker(to: value, columns: columns)
            }
        }
        get {
            return internalValue
        }
    }
    
    private var internalValue: Measurement<UnitType>?
    

    @objc private func onTextChanged() {
        guard let text = internalTextField.text else { return }
        
        if case .picker = inputType { // handle "clear" button
            if text.isEmpty {
                internalValue = nil
                onValueChanged(nil)
            }
            return
        }
        
        guard case let .keyboardInput(unit, _) = inputType else { return }
        guard let decimalValue = doubleFromString(text) else {
            internalValue = nil
            onValueChanged(nil)
            return
        }
        internalValue = Measurement(value: decimalValue, unit: unit)
        onValueChanged(value)
    }
    

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        guard case let .picker(columns) = inputType else {
            assert(false)
            return 0
        }
        return columns.count
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard case .keyboardInput = inputType else { return false }
        guard let text = textField.text as NSString? else { return false }
        let newText = text.replacingCharacters(in: range, with: string)
        return doubleFromString(newText) != nil || newText.isEmpty
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard case let .picker(columns) = inputType else {
            assert(false)
            return 0
        }
        let column = columns[component]
        return column.rows.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard case let .picker(columns) = inputType else {
            assert(false)
            return nil
        }
        let column = columns[component]

        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .providedUnit
        
        let measurement = Measurement(value: column.rows[row], unit: column.unit)
        
        return formatter.string(from: measurement)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard case let .picker(columns) = inputType else {
            assert(false)
            return
        }
        
        let path = pickerView.columnPath
        showValue(for: path, columns: columns)
        self.internalValue = value(at: path, in: columns)
        self.onValueChanged(self.internalValue)
    }
    
    private func value(at columnPath: ColumnPath, in columns: [PickerColumn<UnitType>]) -> Measurement<UnitType>? {
        var measurements: [Measurement<UnitType>] = []
        for (columnIndex, rowIndex) in columnPath.enumerated() {
            let column = columns[columnIndex]
            let value = column.rows[rowIndex]
            
            let measurement = Measurement(value: value, unit: column.unit)
            measurements.append(measurement)
        }
        return sumOf(measurements)
    }
    
    private func showValue(for path: ColumnPath, columns: [PickerColumn<UnitType>]) {
        var formattedValues: [String] = []
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        
        for (columnIndex, rowIndex) in path.enumerated() {
            let column = columns[columnIndex]
            let row = column.rows[rowIndex]
            
            let measurement = Measurement(value: row, unit: column.unit)
            formattedValues.append(formatter.string(from: measurement))
        }
        
        self.internalTextField.text = formattedValues.joined(separator: " ")
    }
    
    private func setPicker(to value: Measurement<UnitType>?, columns: [PickerColumn<UnitType>]) {
        guard let value = value else { return }
        
        var columnPath: ColumnPath = []
        var accumulator: Measurement<UnitType>?
        
        for (columnIndex, column) in columns.enumerated() {
            columnPath.append(0)
            
            let convertedValue: Measurement<UnitType>
            if let accumulator = accumulator {
                convertedValue = value.converted(to: column.unit) - accumulator.converted(to: column.unit)
            } else {
                convertedValue = value.converted(to: column.unit)
            }
            for (rowIndex, row) in column.rows.enumerated() {
                if row - convertedValue.value > 0.0 {
                    columnPath[columnIndex] = max(0, rowIndex - 1)
                    break
                }
            }
            
            let selectedValue = column.rows[columnPath[columnIndex]]
            let selectedMeasurement = Measurement(value: selectedValue, unit: column.unit)
            accumulator = accumulator.flatMap { $0 + selectedMeasurement } ?? selectedMeasurement
        }
        
        assert(columnPath.count == columns.count)
        
        for (column, row) in columnPath.enumerated() {
            pickerView.selectRow(row, inComponent: column, animated: false)
        }
        showValue(for: columnPath, columns: columns)
    }
    
    private func sumOf(_ measurements: [Measurement<UnitType>]) -> Measurement<UnitType>? {
        guard measurements.count > 1 else { return measurements.first }
        return measurements[1...].reduce(measurements[0], +)
    }
 
    private func doubleFromString(_ string: String) -> Double? {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: string).flatMap { $0.doubleValue }
    }
    
    private func stringFromDouble(_ double: Double) -> String? {
        let numberFormatter = NumberFormatter()
        return numberFormatter.string(from: double as NSNumber)
    }
}

