//
//  InputType.swift
//  MeasurementTextField
//
//  Created by Siarhei Fedartsou on 1/14/18.
//

import Foundation

public enum InputType<UnitType: Dimension> {
    case keyboard(UnitType)
    case picker([PickerColumn<UnitType>])
}
