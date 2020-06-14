//
//  TestData.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public let testMessages = [
  OZMessage(announcement: "CollectionView"),
  OZMessage(false, content: "This is an advance example demostrating what OZChattingUI can do."),
  OZMessage(false, content: "Checkout the source code to see how "),
  OZMessage(false, content: "OZChattingUI is a library designed to simplify the development of UI for such a trivial task as chat. It has flexible possibilities for styling, customizing. It is also contains example for fully customizable UI."),
  OZMessage(false, content: "Sic autem rejicientes illa omnia, de quibus aliquo modo possumus dubitare, ac etiam, falsa esse fingentes, facilè quidem, supponimus nullum esse Deum, nullum coelum, nulla corpora; nosque etiam ipsos, non habere manus, nec pedes, nec denique ullum corpus, non autem ideò nos qui talia cogitamus nihil esse: repugnat enim ut putemus id quod cogitat eo ipso tempore quo cogitat non existere. Ac proinde haec cognitio, ego cogito, ergo sum."),
  OZMessage(true, content: "Test Content"),
  OZMessage(announcement: "Today 9:30 AM"),
  OZMessage(true, image: "l1"),
  OZMessage(true, image: "l2"),
  OZMessage(true, image: "l3"),
  OZMessage(true, content: "Suspendisse ut turpis."),
  OZMessage(true, content: "velit."),
  OZMessage(false, content: "Suspendisse ut turpis velit."),
  OZMessage(true, content: "Nullam placerat rhoncus erat ut placerat."),
  OZMessage(false, content: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
  OZMessage(false, content: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
  OZMessage(false, content: "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."),
  OZMessage(false, image: "1"),
  OZMessage(false, image: "2"),
  OZMessage(false, image: "3"),
  OZMessage(false, image: "4"),
  OZMessage(false, image: "5"),
  OZMessage(false, image: "6"),
  OZMessage(true, content: "Images are packed as its own size."),
  OZMessage(announcement: "Fri, Feb 7, 2020"),
  OZMessage(false, content: "Good luck ;)"),
  OZMessage(true, content: "Have a great day!"),
  OZMessage(false, content: "You too."),
  OZMessage(deviceStatus: "Vivi called with you for 9 minutes.", statusType: OZMessageDeviceType.call),
  OZMessage(false, mp3: "test.mp3"),
  OZMessage(deviceStatus: "Sally joined Koala's event", statusType: OZMessageDeviceType.campaign),
  OZMessage(deviceStatus: "Apple Watch", statusType: OZMessageDeviceType.watchOff),
  OZMessage(true, mp3: "test.mp3"),
  OZMessage(true, emoticon: "oz1014"),
  OZMessage(true, status: "Delivered"),
]

let testImages: [UIImage] = [
  UIImage(named: "l1")!,
  UIImage(named: "l2")!,
  UIImage(named: "l3")!,
  UIImage(named: "1")!,
  UIImage(named: "2")!,
  UIImage(named: "3")!,
  UIImage(named: "4")!,
  UIImage(named: "5")!,
  UIImage(named: "6")!
]
