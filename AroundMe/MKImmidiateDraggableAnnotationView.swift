//
//  MKImmidiateDraggablePinAnnotationView.swift
//  AroundMe
//
//  Created by Rohit Kondekar on 11/29/15.
//  Copyright © 2015 Rohit Kondekar. All rights reserved.
//

import UIKit
import MapKit

class MKImmidiateDraggableAnnotationView: MKAnnotationView {

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selected = true
        super.touchesBegan(touches, withEvent: event)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
