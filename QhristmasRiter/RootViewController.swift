import SwiftUI
import SwiftPizzaSnips
import PDFKit

protocol RootViewControllerCoordinator: Coordinator {}

class RootViewController: NSViewController {
	private let mainView: PDFView

	unowned let coordinator: RootViewControllerCoordinator

	init(
		coordinator: RootViewControllerCoordinator
	) {
		self.coordinator = coordinator
		self.mainView = PDFView()

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		let view = NSView()
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.underPageBackgroundColor.cgColor
		self.view = view
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		var constraints: [NSLayoutConstraint] = []
		defer { NSLayoutConstraint.activate(constraints) }

		constraints += [
			view.widthAnchor.constraint(greaterThanOrEqualToConstant: 480),
			view.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
		]

		view.addSubview(mainView)
		constraints += view.constrain(mainView)
	}

	@objc
	func saveDocument(_ sender: NSMenuItem) {
		guard let doc = mainView.document else { return }
		let savePanel = NSSavePanel()
		savePanel.nameFieldStringValue = "qrCodes"
		savePanel.currentContentType = .pdf

		let result = savePanel.runModal()
		guard
			result == .OK,
			let url = savePanel.url
		else { return }

		guard
			doc.write(to: url)
		else {
			return print("Error writing to file")
		}
	}

	override func responds(to aSelector: Selector?) -> Bool {
		guard
			let aSelector,
			aSelector == #selector(saveDocument(_:))
		else { return super.responds(to: aSelector) }

		return mainView.document != nil
	}

	func display(pdfData: Data) throws(Error) {
		guard let pdfDoc = PDFDocument(data: pdfData) else {
			throw .invalidPdfData
		}
		mainView.document = pdfDoc
	}

	enum Error: Swift.Error {
		case invalidPdfData
	}
}
