//import Cocoa
import CoreImage
import Quartz

enum Qreator {
	static func generateQRCode(uuid: UUID = UUID(), size: Double = 72) -> NSImage? {
		generateQRCode(uuid.uuidString, size: size)
	}

	static func generateQRCode(_ text: String, size: Double = 72) -> NSImage? {
		let data = Data(text.utf8)
		guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
		filter.setValue(data, forKey: "inputMessage")
		filter.setValue("Q", forKey: "inputCorrectionLevel")
		guard let outputImage = filter.outputImage else { return nil }

		let transform = CGAffineTransform(
			scaleX: (size * 5) / outputImage.extent.size.width,
			y: (size * 5) / outputImage.extent.size.height)

		let rep = NSCIImageRep(ciImage: outputImage.transformed(by: transform))
		let nsImage = NSImage(size: rep.size)
		nsImage.addRepresentation(rep)
		return nsImage
	}

	static func generate128Barcode(_ text: String, sizeMultiplier: Double = 5) -> NSImage? {
		guard let data = text.data(using: .ascii) else { return nil }
		guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
		filter.setValue(data, forKey: "inputMessage")
//		filter.setValue("Q", forKey: "inputCorrectionLevel")
		guard let outputImage = filter.outputImage else { return nil }

		let transform = CGAffineTransform(
			scaleX: sizeMultiplier,
			y: sizeMultiplier)

		let rep = NSCIImageRep(ciImage: outputImage.transformed(by: transform))
		let nsImage = NSImage(size: rep.size)
		nsImage.addRepresentation(rep)
		return nsImage
	}

	static func generate417Barcode(_ text: String, sizeMultiplier: Double = 5) -> NSImage? {
		guard let data = text.data(using: .ascii) else { return nil }
		guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else { return nil }
		filter.setValue(data, forKey: "inputMessage")
		filter.setValue(((1.75/0.666667) as NSNumber), forKey: "inputPreferredAspectRatio")
		guard let outputImage = filter.outputImage else { return nil }

		let transform = CGAffineTransform(
			scaleX: sizeMultiplier,
			y: sizeMultiplier)

		let rep = NSCIImageRep(ciImage: outputImage.transformed(by: transform))
		let nsImage = NSImage(size: rep.size)
		nsImage.addRepresentation(rep)
		return nsImage
	}



}
