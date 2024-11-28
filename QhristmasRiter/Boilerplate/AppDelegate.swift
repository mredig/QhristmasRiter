import Cocoa

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow!

	let rootCoordinator: RootCoordinator

	init(rootCoordinator: RootCoordinator) {
		self.rootCoordinator = rootCoordinator

		super.init()
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		rootCoordinator.start()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}

