import AppKit

@MainActor
@main
struct AppLauncher {
	static func main() async throws {
		let app = NSApplication.shared
		Bundle.main.loadNibNamed("MainMenu", owner: app, topLevelObjects: nil)
		let rootCoordinator = try RootCoordinator()
		let delegate = AppDelegate(rootCoordinator: rootCoordinator)
		NSApplication.shared.delegate = delegate
		app.run()
	}
}
