//
//  TestData.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public let testOneMessages = [
    OZMessage(announcement: "OZPLACEHOLDER"),
]
public let testMessages = [
  OZMessage(announcement: "CollectionView"),
  OZMessage(false, content: "This is an advance example demostrating what CollectionView can do."),
  OZMessage(false, content: "Checkout the source code to see how "),
  OZMessage(false, content: "Nulla fringilla, dolor id congue elementum, urna diam rhoncus eros, sit amet hendrerit turpis velit eget nisl."),
  OZMessage(false, content: "Quisque nulla sapien, dignissim ac risus nec, vehicula commodo lectus. Suspendisse lacinia mi sit amet nulla semper sollicitudin."),
  OZMessage(true, content: "Test Content"),
  OZMessage(announcement: "Today 9:30 AM"),
  OZMessage(true, image: "l1"),
  OZMessage(true, image: "l2"),
  OZMessage(true, image: "l3"),
  OZMessage(true, content: "Suspendisse ut turpis."),
  OZMessage(true, content: "velit."),
  OZMessage(false, content: "Suspendisse ut turpis velit."),
  OZMessage(true, content: "Nullam placerat rhoncus erat ut placerat."),
  OZMessage(false, content: "Fusce cursus metus viverra erat viverra, sed efficitur magna consequat. Ut tristique magna et sapien euismod, consequat maximus ipsum varius."),
  OZMessage(false, content: "Nulla mattis odio a tortor fringilla pulvinar. Curabitur laoreet, velit nec malesuada finibus, massa arcu aliquam ex, a interdum justo massa eget erat. Curabitur facilisis molestie arcu id porta. Phasellus commodo rutrum mi a elementum. Etiam vestibulum volutpat sem, tincidunt auctor elit lobortis in. Pellentesque pellentesque tortor lectus, sed cursus augue porta vitae. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."),
  OZMessage(false, content: "In bibendum nisl at arcu mollis volutpat vitae eu urna. Mauris sodales iaculis lorem, nec rutrum dui ullamcorper nec. Fusce nibh dolor, mollis ac efficitur condimentum, vulputate eget erat. Sed molestie neque eu blandit placerat. Fusce nec sagittis nulla. Sed aliquam elit sollicitudin egestas convallis. Vestibulum vel sem vel lectus porta tempus. Curabitur semper in nulla id lacinia. Sed consequat massa nisi, sed egestas quam facilisis id."),
  OZMessage(false, image: "1"),
  OZMessage(false, image: "2"),
  OZMessage(false, image: "3"),
  OZMessage(false, image: "4"),
  OZMessage(false, image: "5"),
  OZMessage(false, image: "6"),
  OZMessage(true, content: "Etiam a leo nibh. Fusce cursus metus viverra erat viverra, sed efficitur magna consequat. Ut tristique magna et sapien euismod, consequat maximus ipsum varius."),
  OZMessage(announcement: "Fri, Feb 7, 2020"),
  OZMessage(false, content: "Suspendisse ut turpis velit."),
  OZMessage(true, content: "Vivamus et fermentum diam. Suspendisse vitae tempor lectus."),
  OZMessage(true, content: "Duis eros eros", timestamp: 1589136050),
  OZMessage(true, status: "Delivered"),
  OZMessage(deviceStatus: "Vivi called with you for 9 minutes.", statusType: OZMessageDeviceType.call),
  OZMessage(false, mp3: "test.mp3"),
  OZMessage(deviceStatus: "Sally joined Koala's event", statusType: OZMessageDeviceType.campaign),
  OZMessage(deviceStatus: "Apple Watch", statusType: OZMessageDeviceType.watchOff),
  OZMessage(true, mp3: "test.mp3"),
  OZMessage(true, image: "1020"),
  OZMessage(true, status: "Delivered"),
  //Message(false, image: "6"),
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
