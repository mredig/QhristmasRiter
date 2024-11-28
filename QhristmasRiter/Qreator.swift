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
}
