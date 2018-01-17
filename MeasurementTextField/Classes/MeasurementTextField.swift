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

public final class MeasurementTextField<UnitType: Dimension>: UITextField, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        return pickerView
    }()
    
    private lazy var unitLabel: UILabel = {
        let unitLabel = UILabel()
        unitLabel.textColor = tintColor
        unitLabel.font = font
        return unitLabel
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
    
    private var showCaret: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override func caretRect(for position: UITextPosition) -> CGRect {
        return showCaret ? super.caretRect(for: position) : .zero
    }
    
    private weak var realDelegate: UITextFieldDelegate?
    public override weak var delegate: UITextFieldDelegate? {
        set {
            realDelegate = newValue
        }
        get {
            return realDelegate
        }
    }
    
    private func setup() {
        keyboardType = .decimalPad
        super.delegate = self
        addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
        
        switch inputType {
        case let .keyboardInput(unit, showMeasureUnit):
            guard showMeasureUnit else { return }
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .short
            unitLabel.text = formatter.string(from: unit)
            unitLabel.sizeToFit()
            unitLabel.frame.size.width += Layout.measureUnitLabelRightInset
            rightView = unitLabel
            rightViewMode = .always
        case .picker:
            inputView = pickerView
            showCaret = false
            clearButtonMode = .whileEditing
        }
        
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        unitLabel.textColor = tintColor
    }
    
    public override var font: UIFont? {
        didSet {
            unitLabel.font = font
        }
    }
    
    public var value: Measurement<UnitType>? {
        set {
            internalValue = newValue
            
            switch inputType {
            case let .keyboardInput(unit, _):
                guard let value = value else {
                    text = ""
                    return
                }
                let convertedValue = value.converted(to: unit)
                text = stringFromDouble(convertedValue.value)
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
        guard let text = self.text else { return }
        
        if case .picker = inputType { // handle "clear" button
            if text.isEmpty {
                internalValue = nil
                sendActions(for: .valueChanged)
            }
            return
        }
        
        guard case let .keyboardInput(unit, _) = inputType else { return }
        guard let decimalValue = doubleFromString(text) else {
            internalValue = nil
            sendActions(for: .valueChanged)
            return
        }
        internalValue = Measurement(value: decimalValue, unit: unit)
        sendActions(for: .valueChanged)
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
        
        text = formattedValues.joined(separator: " ")
    }
    
    private func setPicker(to value: Measurement<UnitType>?, columns: [PickerColumn<UnitType>]) {
        guard let value = value else { return }
        
        var columnPath: ColumnPath = []
        var accumulator: Measurement<UnitType>?
        
        let threshold = 0.0001
        
        for (columnIndex, column) in columns.enumerated() {
            columnPath.append(0)
            
            let convertedValue: Measurement<UnitType>
            if let accumulator = accumulator {
                convertedValue = value.converted(to: column.unit) - accumulator.converted(to: column.unit)
            } else {
                convertedValue = value.converted(to: column.unit)
            }
            
            for (rowIndex, row) in column.rows.enumerated() {
                if abs(row - convertedValue.value) < threshold {
                    columnPath[columnIndex] = rowIndex
                    break
                }
            }
            
            // handle edge cases
            if let first = column.rows.first, (first > convertedValue.value || abs(first - convertedValue.value) < threshold) {
                columnPath[columnIndex] = 0
            } else if let last = column.rows.last, (last < convertedValue.value || abs(last - convertedValue.value) < threshold) {
                columnPath[columnIndex] = column.rows.count - 1
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
    
    // MARK UIPickerViewDelegate/UIPickerViewDataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        guard case let .picker(columns) = inputType else {
            assert(false)
            return 0
        }
        return columns.count
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
        sendActions(for: .valueChanged)
    }
    
    
    // MARK: UITextFieldDelegate
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard case .keyboardInput = inputType else { return false }
        guard let text = textField.text as NSString? else { return false }
        let newText = text.replacingCharacters(in: range, with: string)
        return doubleFromString(newText) != nil || newText.isEmpty
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return realDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        realDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return realDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        realDelegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        realDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return realDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return realDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
}
