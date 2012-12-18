# Transformifier

Generic Interactive 3D Transformation Tweaking Tool for iOS Development

**The scenario:**  
Your designer hands you psd or png files to skin the app. 

No problem. Except there's this element that's like this original element, except it's skewed just so. 

The gotcha: the element is dynamic at runtime.  Thus, you can't simply save the designer's sample as a static png. You must render the element and recreate the skew in code.

And no, the transformation values are not available, since they were applied freehand in Photoshop.

**One approach:**  
After spending an inordinate amount of time applying a series of transforms in a never-ending trial-and-error nightmare, you realize it's not a simple 2D skew, or even couple of 3D axis rotations. What the heck did the designer do?

**A Better Idea:**  
Temporarily install and instantiate a Transformifier. Set it to act on the CALayer of the victim element on the screen, and interactively set functions and values until you get exactly the desired effect. Click the output icon to get fully formed, ready to paste text to replicate the effect in code.

## Installation:

1 Copy the 2 files in the Transformifier folder and add them to your project:

	* Transformifier.h
	* Transformifier.m
	
2 Add this line to the UIViewController's implementation file where you need some transformication:

	* #import "Transformifier.h"

3 Ensure QuartzCore.framework is part of the project, and #import <QuartzCore/QuartzCore.h> as appropriate.

4 Instantiate a Transformifier and add it's view to your view controller's superview. Be sure to retain the Transformifier in the host view controller.

5 Optionally set the transformifier's yOffset or height properties to allow a better view of the UI element being transformified.


### Example code usage:

	- (void)viewDidAppear:(BOOL)animated {
		[super viewDidAppear:animated];

		self.transformifier = [[Transformifier alloc] initForLayer:victimLabel.layer];
		[self.view.superview insertSubview:transformifier.view aboveSubview:self.view];
	}

## Sample App

You'll need to download this entire repo for the sample app to work, as the Transformifier.xcodeproj references both the Transformifier and Sample App top level folders (plus the snazzy 10-minute-photoshop-hack app icons).

## Tool usage:


1 The transformifier instantiates as a UITableView with 2 sections. 

* The first section contains the active transforms, while the second is used as a source of new transforms or a dump of unneeded transforms.

![Transformifier Table Sections](Transformifier/wiki/images/transformifier1.png)

2 Each row in the table describes what that transform does. 

* Use the slider to adjust the amount of transformation, and the segmented control to choose which axis to act upon.

![Transformifier Table Sections](Transformifier/wiki/images/transformifier2.png)
 
3 Move rows from the source section to the active section to add a new transform.

* Move rows from the active section to the source section to remove its effect. 
* The source section will always contain one of each type of transform regardless of what you move out or into it. 
* You can add as many transforms as you need to achieve the affect you need.  


4 Since some transforms are not commutative, you may reorder them in the active section to get a different effect.

* Reordering rows in the source section has no effect, except possibly placing a frequently used transform within easier reach.  


5 If you get tangled up, click the reload button to tango on.  


6 Once your target effect is achieved, click the actions button to reveal the code needed to replicate it.

* Click in the new visible UITextView to copy its contents to the iOS pasteboard in the simulator
* Press ⌘-c to copy the code to the OSX clipboard, then paste it into xcode.
* There are 3 types of output:
	* A human-readable description of all the transforms applied
	* A set of CATransform3D functions to replicate the transforms in code
	* A single CATransform3D containing the final, concatenated effect of the active transforms.
* Use either the step-by-step transform functions or the final aggregate to apply to your target UI element's layer.  

![Transformifier Table Sections](Transformifier/wiki/images/transformifier3.png)  
![Transformifier Table Sections](Transformifier/wiki/images/transformifier4.png)  
![Transformifier Table Sections](Transformifier/wiki/images/transformifier5.png)  




## License

Copyright (c) 2012 eMaza Mobile. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

