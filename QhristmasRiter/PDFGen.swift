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

		let page = PDFLayout.avery5195()

		for (image, placement) in zip(images, page.placementItems()) {

			let imageSize = CGSize(scalar: placement.size.min) - CGSize(width: 2, height: 2)
			let imageBox = placement.absoluteCenterPlace(ofItemWithSize: imageSize)

			var cgRect = NSRect(origin: .zero, size: imageSize)
			guard
				let cgImage = image.cgImage(forProposedRect: &cgRect, context: nil, hints: nil),
				pdfContext.draw(cgImage, in: imageBox, options: nil)
			else { continue }
//			print("\(imageBox)")
		}

		pdfContext.endPDFPage()
		pdfContext.closePDF()

		return Data(pdfData)
	}
}
