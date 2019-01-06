//
//  TypedViewControllerProvider.swift
//  Sentinel
//
//  Created by Ceri Hughes on 06/01/2019.
//  Copyright © 2019 Ceri Hughes. All rights reserved.
//

import Madog
import UIKit

class TypedViewControllerProvider: ViewControllerProviderObject {
    private var uuid: UUID?

    // MARK: ViewControllerProviderObject

    final override func register(with registry: ViewControllerRegistry) {
        uuid = registry.add(registryFunction: createViewController(token:context:))
    }

    final override func unregister(from registry: ViewControllerRegistry) {
        guard let uuid = uuid else {
            return
        }

        registry.removeRegistryFunction(uuid: uuid)
    }

    func createViewController(registrationLocator: RegistrationLocator, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        return nil // Override
    }

    // Private

    private func createViewController(token: Any, context: Context) -> UIViewController? {
        guard let registrationLocator = token as? RegistrationLocator,
            let navigationContext = context as? ForwardBackNavigationContext else {
                return nil
        }

        return createViewController(registrationLocator: registrationLocator, navigationContext: navigationContext)
    }
}
