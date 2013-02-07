//  ViewController.m
//  Created by erwin on 12/14/12.

/*
 
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
 
*/


#import "ViewController.h"
#import "Transformifier.h"

@interface ViewController ()

	@property (nonatomic, strong) Transformifier *transformifier;

@end

@implementation ViewController

@synthesize victimLabel, transformifier;

- (void)viewDidLoad {
	LogMethod
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	LogMethod
	[super viewDidAppear:animated];
	self.transformifier = [[Transformifier alloc] initForLayer:victimLabel.layer];

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		transformifier.yOffset = 25;
		transformifier.height = 350;
	} else {
		transformifier.yOffset = 100;
		transformifier.height = 850;
	}

	transformifier.view.alpha = 0.0;
	
	[self.view.superview insertSubview:transformifier.view aboveSubview:self.view];

	[UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
		transformifier.view.alpha = 1.0;
	} completion:^(BOOL finished){	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
