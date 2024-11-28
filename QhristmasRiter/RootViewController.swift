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
