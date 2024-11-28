import AppKit
import SwiftPizzaSnips

protocol RootWindowControllerCoordinator: RootViewControllerCoordinator {
	func rootWindowControllerDidPressProfileButton(_ rootWindowController: RootWindowController)
}

class RootWindowController: NSWindowController {
	let toolbar = NSToolbar(identifier: "Root Window Toolbar")

	static let profileToolbarItemIdentifier = NSToolbarItem.Identifier("Profile")
	let profileToolbarItem = NSToolbarItem(itemIdentifier: RootWindowController.profileToolbarItemIdentifier).with {
		$0.label = "Profile"
		$0.paletteLabel = "Profile"
		$0.toolTip = "View your Account"
		guard
			let image = NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: nil)
		else { return }
		$0.image = image
		$0.isBordered = true
	}
	var vc: RootViewController? { window?.contentViewController as? RootViewController }

	unowned let rootVCCoordinator: RootWindowControllerCoordinator

	private var bag: Bag = []

	init(
		rootVCCoordinator: RootWindowControllerCoordinator
	) {
		self.rootVCCoordinator = rootVCCoordinator
		super.init(window: nil)

		let rootViewController = RootViewController(coordinator: rootVCCoordinator)
		let window = NSWindow(contentViewController: rootViewController)
		window.styleMask.remove(.closable)
		window.title = "QhristmasRiter"
		self.window = window

		toolbar.delegate = self
		window.toolbar = toolbar
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc func profileToolbarItemPressed(_ sender: Any) {
		rootVCCoordinator.rootWindowControllerDidPressProfileButton(self)
	}

	func enableToolbarItem(withIdentifier identifier: NSToolbarItem.Identifier, _ flag: Bool) {
		guard
			let item = toolbar.items.first(where: { $0.itemIdentifier == identifier })
		else { return }
		item.isEnabled = flag
	}
}

extension RootWindowController: NSToolbarDelegate, NSToolbarItemValidation {
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[
			.flexibleSpace,
			Self.profileToolbarItemIdentifier,
		]
	}

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[
			.flexibleSpace,
			Self.profileToolbarItemIdentifier,
		]
	}

	func toolbar(
		_ toolbar: NSToolbar,
		itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
		willBeInsertedIntoToolbar flag: Bool
	) -> NSToolbarItem? {
		switch itemIdentifier {
		case Self.profileToolbarItemIdentifier:
			profileToolbarItem.target = self
			profileToolbarItem.action = #selector(profileToolbarItemPressed)
			return profileToolbarItem
		default:
			return nil
		}
	}

	func validateToolbarItem(_ item: NSToolbarItem) -> Bool { true }
}
