import Cocoa
import VectorExtor

enum PDFGen {
	static func createUSLetterPDF(from images: [NSImage], imageSize: Double, spacing: Double, pageMargin: Double) -> Data? {
		let pdfData = NSMutableData()
		let cfPDFData = pdfData as CFMutableData
		var pageBox = CGRect(origin: .zero, size: CGSize(width: 612, height: 792))

		guard
			let consumer = CGDataConsumer(data: cfPDFData),
			let pdfContext = CGContext(consumer: consumer, mediaBox: &pageBox, nil)
		else { return nil }
		pdfContext.beginPDFPage(nil)
//		pdfContext.interpolationQuality = .none

		let mediaBox = pageBox.insetBy(dx: pageMargin, dy: pageMargin)

		let period = imageSize + spacing

		for (index, image) in images.enumerated() {
			let offset = Double(index) * period
			let xOffset = offset.truncatingRemainder(dividingBy: mediaBox.width)
			let yOffset = Double(Int(offset) / Int(mediaBox.width)) * period
			let imageBox = CGRect(
				origin: CGPoint(x: pageMargin + xOffset, y: pageMargin + yOffset),
				size: CGSize(scalar: imageSize))

			var cgRect = NSRect(origin: .zero, size: image.size)
			guard
				let cgImage = image.cgImage(forProposedRect: &cgRect, context: nil, hints: nil),
				pdfContext.draw(cgImage, in: imageBox, options: nil)
			else { continue }
			print("\(index): \(imageBox)")
		}

		pdfContext.endPDFPage()
		pdfContext.closePDF()

		return Data(pdfData)
	}
}
