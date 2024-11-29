import Foundation

enum PDFLayout {
	protocol RowItem: Hashable {
		var id: UUID { get }
		/// in points, with 72 dpi
		var width: Double { get }

		func copy() -> Self
	}

	protocol ConstantWidth: RowItem {
		init(width: Double)
		init(measurement: Measurement<UnitLength>)
	}

	protocol HPlaceable: RowItem {
		func centerXPlacement(forItemOfWidth innerItemWidth: Double) -> Double
	}

	struct Sticker: ConstantWidth, HPlaceable {
		let id = UUID()
		let width: Double

		func centerXPlacement(forItemOfWidth innerItemWidth: Double) -> Double {
			let remainingGap = width - innerItemWidth
			return remainingGap / 2
		}
	}

	struct Gap: ConstantWidth, RowItem {
		let id = UUID()
		let width: Double
	}

	struct Row: RowItem {
		let id = UUID()
		let items: [any RowItem]
		let height: Double
		var width: Double {
			minimumContainerWidth()
		}

		init(items: [any RowItem], height: Double) {
			self.items = items
			self.height = height
		}

		init(items: [any RowItem], height: Measurement<UnitLength>) {
			self.init(items: items, height: height.converted(to: .points).value)
		}

		static func gap(height: Double) -> Row {
			Row(items: [Gap(width: 0)], height: height)
		}

		subscript(placement: Int) -> (any HPlaceable)? {
			guard items.indices ~= placement else { return nil }
			var index = 0
			for item in items {
				guard let hplace = item as? (any HPlaceable) else { continue }
				defer { index += 1 }
				if index == placement {
					return hplace
				}
			}
			return nil
		}

		func placementCount() -> Int {
			items.filter { $0 is (any HPlaceable) }.count
		}

		func xOffset<I: RowItem>(of item: I) -> Double? {
			guard let index = items.firstIndex(where: { ($0 as? I) == item }) else { return nil }

			return (items.startIndex..<index).map { items[$0].width }.reduce(0, +)
		}

		func minimumContainerWidth() -> Double {
			items.map(\.width).reduce(0, +)
		}

		func centerYPlacement(forItemOfHeight innerItemHeight: Double) -> Double {
			let remainingGap = height - innerItemHeight
			return remainingGap / 2
		}

		func copy() -> PDFLayout.Row {
			Row(items: items.map { $0.copy() }, height: height)
		}
	}

	struct Page: CustomStringConvertible {
		let margins: NSEdgeInsets
		let rows: [Row]

		var width: Double {
			(rows.map(\.width).min() ?? 0) + margins.left + margins.right
		}

		var height: Double {
			rows.map(\.height).reduce(0, +) + margins.top + margins.bottom
		}

		var size: CGSize { CGSize(width: width, height: height) }

		var description: String {
			"""
			Page: margins: \(margins)
			rows: \(rows.map(String.init(describing:)).joined(separator: "\n"))
			dimensions: \(size)
			(\(Measurement(value: width, unit: UnitLength.points).converted(to: .centimeters)), \(Measurement(value: height, unit: UnitLength.points).converted(to: .centimeters)))
			"""
		}

		init(margins: NSEdgeInsets, rows: [Row]) {
			self.margins = margins
			self.rows = rows.map { $0.copy() }
		}

		subscript(placement: Int) -> (any HPlaceable)? {
			var startOffset = 0
			for row in rows {
				let placementCount = row.placementCount()
				defer { startOffset = placementCount }
				let placementRange = startOffset..<placementCount
				guard placementRange ~= placement else {
					continue
				}

				let rowPlacement = placement - startOffset
				return row[rowPlacement]
			}
			return nil
		}

		func placement<I: RowItem>(of item: I) -> CGRect? {
			var currentHeight = margins.bottom
			for row in rows {
				guard let xOffset = row.xOffset(of: item) else {
					currentHeight += row.height
					continue
				}
				return CGRect(x: xOffset, y: currentHeight, width: item.width, height: row.height)
			}
			return nil
		}

		func placementCount() -> Int {
			rows.map { $0.placementCount() }.reduce(0, +)
		}
	}

}

extension PDFLayout.ConstantWidth {
	init(measurement: Measurement<UnitLength>) {
		let points = measurement.converted(to: .points)
		self.init(width: points.value)
	}
}

extension PDFLayout.ConstantWidth {
	func copy() -> Self {
		Self(width: width)
	}
}

extension PDFLayout.RowItem {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine("\(Self.self)")
	}
}
