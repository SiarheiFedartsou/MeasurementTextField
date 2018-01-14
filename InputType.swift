//
//  InputType.swift
//  MeasurementTextField
//
//  Created by Siarhei Fedartsou on 1/14/18.
//

import Foundation

public enum InputType<UnitType: Dimension> {
    case keyboardInput(UnitType, showMeasureUnit: Bool)
    case picker([PickerColumn<UnitType>])
    
    public static func keyboard(_ unit: UnitType, showMeasureUnit: Bool = true) -> InputType<UnitType> {
        return .keyboardInput(unit, showMeasureUnit: showMeasureUnit)
    }
}
