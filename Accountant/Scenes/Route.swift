//
//  Route.swift
//  Accountant
//
//  Created by Roman Topchii on 08.05.2022.
//

import Foundation
import UIKit

protocol RoutingDestinationBase {}

protocol Router {
   associatedtype RoutingDestination: RoutingDestinationBase
   func route(to destination: RoutingDestination)
}
