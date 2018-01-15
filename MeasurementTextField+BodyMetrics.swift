//
//  MeasurementTextField+Person.swift
//  MeasurementTextField
//
//  Created by Siarhei Fedartsou on 1/15/18.
//

import Foundation

public extension MeasurementTextField {
    public class func forBodyHeight(locale: Locale = .current) -> MeasurementTextField<UnitLength> {
        if locale.usesMetricSystem {
            return MeasurementTextField<UnitLength>(inputType: .keyboard(.centimeters))
        } else {
            return MeasurementTextField<UnitLength>(inputType: .picker([
                PickerColumn(unit: UnitLength.feet, range: 0...9),
                PickerColumn(unit: UnitLength.inches, range: 0...11)
            ]))
        }
    }
    
    public class func forBodyWeight(locale: Locale = .current) -> MeasurementTextField<UnitMass> {
        if locale.usesMetricSystem {
            return MeasurementTextField<UnitMass>(inputType: .keyboard(.kilograms))
        } else {
            return MeasurementTextField<UnitMass>(inputType: .keyboard(.pounds))
        }
    }
}
