//
//  PickerColumn.swift
//  MeasurementTextField
//
//  Created by Siarhei Fedartsou on 1/14/18.
//

import Foundation

public struct PickerColumn<UnitType: Dimension> {
    public let unit: UnitType
    
    public let range: ClosedRange<Double>
    public let step: Double
    
    internal let rows: [Double]
    
    public init(unit: UnitType, range: ClosedRange<Double>, step: Double = 1.0) {
        self.unit = unit
        self.range = range
        self.step = step
        
        var rows: [Double] = []
        var row: Double = range.lowerBound
        while row < range.upperBound {
            rows.append(row)
            row += step
        }
        self.rows = rows
    }
}
