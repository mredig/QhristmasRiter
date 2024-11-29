import Foundation

extension UnitLength {
	public static var points: UnitLength {
		UnitLength(symbol: "pts", converter: UnitConverterLinear(coefficient: 0.00035277777777777776))
	}
}
