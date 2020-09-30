//
//  TypedViewControllerProvider.swift
//  Sentinel
//
//  Created by Ceri Hughes on 06/01/2019.
//  Copyright © 2019 Ceri Hughes. All rights reserved.
//

import Madog
import UIKit

class TypedViewControllerProvider: SingleViewControllerProvider<Navigation> {
    // MARK: SingleViewControllerProvider

    override func createViewController(token: Navigation, context: Context) -> UIViewController? {
        guard
            let navigationContext = context as? ForwardBackNavigationContext
        else {
            return nil
        }

        return createViewController(token: token, navigationContext: navigationContext)
    }

    func createViewController(token: Navigation, navigationContext: ForwardBackNavigationContext) -> UIViewController? {
        // Override
        return nil
    }
}
