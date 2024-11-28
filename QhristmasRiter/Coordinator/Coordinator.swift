import AppKit

@MainActor
protocol Coordinator: AnyObject {
	var parentCoordinator: Coordinator? { get }
	var childCoordinators: [Coordinator] { get set }

	var rootController: NSWindowController { get }

	func start()
	/// remember to call `superFinish(_:)` with custom implementations
	func finish() async
	func cleanup() async

	func coordinatorDidFinish(_ coordinator: Coordinator)

	/// remember to call `superChildDidFinish(_:)` with custom implementations
	func childDidFinish(_ child: Coordinator) async
}

extension Coordinator {
	/// Cannot call `super` on protocol extensions, so this pattern allows providing a default
	/// implementation as well as a supplemental call when providing a custom implementation
	func superChildDidFinish(_ child: Coordinator) async {
		guard
			let index = childCoordinators.firstIndex(where: { $0 === child })
		else { return }
		childCoordinators.remove(at: index)
	}

	func childDidFinish(_ child: Coordinator) async {
		await superChildDidFinish(child)
	}

	func superFinish() async {
		coordinatorDidFinish(self)
		await parentCoordinator?.childDidFinish(self)
	}

	func finish() async {
		await cleanup()
		await superFinish()
	}

	func addChildCoordinator(_ childCoordinator: Coordinator, andStart start: Bool = true) {
		childCoordinators.append(childCoordinator)

		if start {
			childCoordinator.start()
		}
	}
}
