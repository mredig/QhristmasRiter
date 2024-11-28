import AppKit
import SwiftPizzaSnips

class RootCoordinator: Coordinator {
	let parentCoordinator: Coordinator? = nil

	var childCoordinators: [Coordinator] = []

	var rootController: NSWindowController { windowController }
	private var windowController: RootWindowController!

	private static let lock = NSLock()

	var window: NSWindow! {
		windowController.window
	}

	private var bag: Bag = []

	init() throws {
		let windowController = RootWindowController(
			rootVCCoordinator: self)
		self.windowController = windowController
	}

	func start() {
		do {
			try checkAppLaunchDirectory()
		} catch {
			let app = NSRunningApplication.current
			let appName = app.localizedName
				?? app.executableURL?.deletingPathExtension().lastPathComponent
				?? app.description

			let alert = NSAlert()
			alert.messageText = "Launch detected from directory other than /Applications"
			alert.informativeText = """
				Please move \(appName) to the /Applications directory and open it again.
				"""
			let quitButton = alert.addButton(withTitle: "Quit So I Can Move The App")
			quitButton.tag = 1
			quitButton.keyEquivalent = "\r"

			let response = alert.runModal()

			if response.rawValue == quitButton.tag {
				NSApp.terminate(self)
			}
		}

		windowController.showWindow(self)
	}

	func cleanup() async {}

	func coordinatorDidFinish(_ coordinator: Coordinator) {}

	private func checkAppLaunchDirectory() throws {
		#if !DEBUG
		guard DefaultsManager.shared[.deploymentMode] == .prod else { return }

		let launchURL = Bundle.main.bundleURL

		let appDirectory = URL.bpapplicationDirectory

		guard
			launchURL.pathComponents.count > appDirectory.pathComponents.count,
			appDirectory.pathComponents == Array(launchURL.pathComponents[0..<appDirectory.pathComponents.endIndex])
		else { throw SimpleError(message: "Not Applications directory") }
		#endif
	}
}

extension RootCoordinator: RootWindowControllerCoordinator {
	func rootWindowControllerDidPressProfileButton(_ rootWindowController: RootWindowController) {
		let imageSize = 72.0
		let qrImages = (0..<35)
			.compactMap { _ in Qreator.generateQRCode(size: imageSize) }
		guard
			let pdfData = PDFGen.createUSLetterPDF(from: qrImages, imageSize: imageSize, spacing: 72/2, pageMargin: 72/2)
		else { return }
		do {
			try rootWindowController.vc?.display(pdfData: pdfData)
		} catch {
			print("Error showing pdf: \(error)")
		}
	}
}

// MARK: - RootViewControllerCoordinator
extension RootCoordinator: RootViewControllerCoordinator {}

// MARK: - Task Perform
extension RootCoordinator {
	enum AlertOption: ExpressibleByBooleanLiteral {
		case noAlert
		case defaultAlert
		case useErrorMessage
		case customInfo(info: String)

		init(booleanLiteral value: BooleanLiteralType) {
			if value {
				self = .defaultAlert
			} else {
				self = .noAlert
			}
		}
	}

	@discardableResult
	func performTask(
		errorMessage: String? = nil,
		alertOption: AlertOption = false,
		action: @escaping () async throws -> Void
	) -> Task<Void, Never> {
		Task {
			do {
				try await action()
			} catch {
				print(errorMessage ?? "There was an async error: \(error)")
				switch alertOption {
				case .noAlert:
					break
				case .useErrorMessage:
					alertUser(withErrorInfoOverride: errorMessage, error: error)
				case .defaultAlert:
					alertUser(error: error)
				case .customInfo(let info):
					alertUser(withErrorInfoOverride: info, error: error)
				}
			}
		}
	}

	@MainActor
	private func alertUser(withErrorInfoOverride errorInfo: String? = nil, error: Error) {
		let message = "An error occurred. Please try again."

		let alert = Alert(title: message, message: errorInfo ?? "\(error)").with {
			$0.actions = [
				.init(title: "Okay", isDefault: true)
			]
		}
		let alertView = alert.createAlert()
		alertView.runModal()
	}
}
