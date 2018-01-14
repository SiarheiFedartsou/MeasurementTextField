//
//  UIPickerView+ColumnPath.swift
//  MeasurementTextField
//
//  Created by Siarhei Fedartsou on 1/14/18.
//

import UIKit

extension UIPickerView {
    var columnPath: ColumnPath {
        var path: ColumnPath = []
        for component in 0..<numberOfComponents {
            let row = selectedRow(inComponent: component)
            path.append(row)
        }
        return path
    }
}
