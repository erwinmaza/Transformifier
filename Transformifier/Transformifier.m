//  Transformifier.m
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

#import "Transformifier.h"

typedef enum {
	transformTypeRotate 	= 1,
	transformTypeTranslate	= 2,
	transformTypeScale		= 3,
	transformTypeSkew		= 4,
	transformTypePerspective= 5
} enumTransformType;

@interface Transformifier()

	@property (nonatomic, strong) CALayer			*layer;
	@property (nonatomic, strong) NSMutableArray	*transformsArray;
	@property (nonatomic, strong) NSMutableArray	*sourceArray;
	@property (nonatomic, strong) UITextView		*outputView;
	@property (nonatomic, strong) UIToolbar			*toolbar;

@end


@implementation Transformifier {
	UITableView *table;
}

@synthesize layer, transformsArray, sourceArray, outputView, toolbar, yOffset, height;

- (id)initForLayer:(CALayer*)aLayer {
	if (self = [super init]) {
		self.layer = aLayer;
		self.yOffset = 0;
		self.height = 350;
	}
	return self;
}

- (void)loadView {
	table = [[UITableView alloc] initWithFrame:CGRectMake(25, yOffset, 270, height) style:UITableViewStyleGrouped];
	table.delegate = self;
	table.dataSource = self;
	table.backgroundView = nil;
	table.editing = TRUE;
	self.view = table;
	[table registerClass:[TransformifierCell class] forCellReuseIdentifier:NSStringFromClass([TransformifierCell class])];
	
	[self reload];
	
	self.outputView = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, 270, height - 100)];
	outputView.layer.cornerRadius = 10;
	outputView.editable = FALSE;
	outputView.alpha = 0.0;
	[self.view addSubview:outputView];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyText)];
	[outputView addGestureRecognizer:tap];

	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	UIBarButtonItem *writeButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(writeTransform)];
	self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, -5, 65, 25)];
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	toolbar.items = @[reloadButton, writeButton];
	[self.view addSubview:toolbar];
}

- (void)reload {
	NSNumber *zeroInt = [NSNumber numberWithInt:0];
	NSMutableDictionary *rotate =		[NSMutableDictionary dictionaryWithDictionary:@{@"type" : [NSNumber numberWithInt:transformTypeRotate],		@"axisIndex" : zeroInt, @"value" : [NSNumber numberWithFloat:  0.0] }];
	NSMutableDictionary *translate =	[NSMutableDictionary dictionaryWithDictionary:@{@"type" : [NSNumber numberWithInt:transformTypeTranslate],	@"axisIndex" : zeroInt, @"value" : [NSNumber numberWithFloat:  0.0] }];
	NSMutableDictionary *scale =		[NSMutableDictionary dictionaryWithDictionary:@{@"type" : [NSNumber numberWithInt:transformTypeScale],		@"axisIndex" : zeroInt, @"value" : [NSNumber numberWithFloat:100.0] }];
	NSMutableDictionary *skew =			[NSMutableDictionary dictionaryWithDictionary:@{@"type" : [NSNumber numberWithInt:transformTypeSkew],		@"axisIndex" : zeroInt, @"value" : [NSNumber numberWithFloat:  0.0] }];
	NSMutableDictionary *perspective =	[NSMutableDictionary dictionaryWithDictionary:@{@"type" : [NSNumber numberWithInt:transformTypePerspective],@"axisIndex" : zeroInt, @"value" : [NSNumber numberWithFloat:  0.0] }];

	self.transformsArray =	[NSMutableArray arrayWithArray:@[ rotate, translate, scale ]];
	self.sourceArray =		[NSMutableArray arrayWithArray:@[ skew, perspective, rotate, translate, scale ]];

	[table reloadData];
	[outputView resignFirstResponder];
	outputView.alpha = 0.0;
}

- (void)applyTransform {
	CATransform3D transform = CATransform3DIdentity;
	CATransform3D tmp = CATransform3DIdentity;
	
	for (NSDictionary *data in transformsArray) {
		int type = [[data valueForKey:@"type"] intValue];
		int axisIndex = [[data valueForKey:@"axisIndex"] intValue];
		float value = [[data valueForKey:@"value"] floatValue];
		
		switch (type) {
			case transformTypeRotate: {
				transform =	CATransform3DRotate(transform,	value * M_PI / 180.0, (axisIndex == 0), (axisIndex == 1), (axisIndex == 2));
				break;
			} case transformTypeTranslate: {
				transform = CATransform3DTranslate(transform, value * (axisIndex == 0), value * (axisIndex == 1), value * (axisIndex == 2));
				break;
			} case transformTypeScale: {
				value = (value / 100) - 1.0;
				transform = CATransform3DScale(transform, value * (axisIndex == 0) + 1.0, value * (axisIndex == 1) + 1.0, value * (axisIndex == 2) + 1.0);
				break;
			} case transformTypeSkew: {
				value = (value / 100.0);
				tmp = CATransform3DIdentity;
				tmp.m21 = value * (axisIndex == 0);
				tmp.m12 = value * (axisIndex == 1);
				transform = CATransform3DConcat(transform, tmp);
				break;
			} case transformTypePerspective: {
				value = (value / 100.0);
				tmp = CATransform3DIdentity;
				tmp.m34 = value;
				transform = CATransform3DConcat(transform, tmp);
				break;
			}
		}
	}

	layer.transform = transform;
}

- (void)writeTransform {

	if (outputView.alpha > 0) {
		outputView.alpha = 0.0;
		return;
	}

	NSString *humanOutput = @"/*\nTransform description:\n";

	NSString *output = @"/* INSTRUCTIONS:\n1- Click here to copy output to the iOS pasteboard.\n2- Press ⌘-c to copy to OSX clipboard.\n3- Paste into xcode.\n4- Optimize code by combining successive, like-kind transforms.\n\n";
	output = [output stringByAppendingString:@" Or, use the final, concatenated transform listed below.\n*/\n"];

	NSString *codeOutput = @"CATransform3D transform = CATransform3DIdentity;\n";
	codeOutput = [codeOutput stringByAppendingString:@"CATransform3D tmp = CATransform3DIdentity;\n"];
	
	for (NSDictionary *data in transformsArray) {
		int axisIndex = [[data valueForKey:@"axisIndex"] intValue];
		float value = [[data valueForKey:@"value"] floatValue];
		int type = [[data valueForKey:@"type"] intValue];
		NSString *axis = (axisIndex == 0)? @"X" : (axisIndex == 1)? @"Y" : @"Z";
		
		switch (type) {
			case transformTypeRotate: {
				humanOutput = [humanOutput stringByAppendingFormat:@"Rotate around %@ by %0.2f degrees\n", axis, value];
				codeOutput = [codeOutput stringByAppendingFormat:@"transform = CATransform3DRotate(transform, %0.4f, %d, %d, %d);\n", value * M_PI / 180.0, (axisIndex == 0), (axisIndex == 1), (axisIndex == 2)];
				break;
			} case transformTypeTranslate: {
				humanOutput = [humanOutput stringByAppendingFormat:@"Translate along %@ by %0.2f points\n", axis, value];
				codeOutput = [codeOutput stringByAppendingFormat:@"transform = CATransform3DTranslate(transform, %0.4f, %0.4f, %0.4f);\n", value * (axisIndex == 0), value * (axisIndex == 1), value * (axisIndex == 2)];
				break;
			} case transformTypeScale: {
				humanOutput = [humanOutput stringByAppendingFormat:@"Scale %@ by %0.2f percent\n", axis, value];
				value = (value / 100) - 1.0;
				codeOutput = [codeOutput stringByAppendingFormat:@"transform = CATransform3DScale(transform, %0.4f, %0.4f, %0.4f);\n", value * (axisIndex == 0) + 1.0, value * (axisIndex == 1) + 1.0, value * (axisIndex == 2) + 1.0];
				break;
			} case transformTypeSkew: {
				humanOutput = [humanOutput stringByAppendingFormat:@"Skew along %@ by %0.2f percent\n", axis, value];
				value = (value / 100.0);
				codeOutput = [codeOutput stringByAppendingFormat:@"tmp = CATransform3DIdentity;\n"];
				codeOutput = [codeOutput stringByAppendingFormat:@"tmp.m21 = %0.4f;\n", value * (axisIndex == 0)];
				codeOutput = [codeOutput stringByAppendingFormat:@"tmp.m12 = %0.4f;\n", value * (axisIndex == 1)];
				codeOutput = [codeOutput stringByAppendingFormat:@"transform = CATransform3DConcat(transform, tmp);\n"];
				break;
			} case transformTypePerspective: {
				humanOutput = [humanOutput stringByAppendingFormat:@"Apply %0.2f percent of perspective\n", value];
				value = (value / 100.0);
				codeOutput = [codeOutput stringByAppendingFormat:@"tmp = CATransform3DIdentity;\n"];
				codeOutput = [codeOutput stringByAppendingFormat:@"tmp.m34 = %0.4f;\n", value];
				codeOutput = [codeOutput stringByAppendingFormat:@"transform = CATransform3DConcat(transform, tmp);\n"];
				break;
			}
		}
	}
	
	output = [output stringByAppendingFormat:@"\n%@*/\n%@", humanOutput, codeOutput];

	CATransform3D finalTransform = layer.transform;
	output = [output stringByAppendingString:@"\n\n// Concatenated Transform:\nCATransform3D finalTransform = CATransform3DIdentity;\n"];
	output = [output stringByAppendingFormat:@"finalTransform.m11 = %0.4f;\n", finalTransform.m11];
	output = [output stringByAppendingFormat:@"finalTransform.m12 = %0.4f;\n", finalTransform.m12];
	output = [output stringByAppendingFormat:@"finalTransform.m13 = %0.4f;\n", finalTransform.m13];
	output = [output stringByAppendingFormat:@"finalTransform.m14 = %0.4f;\n", finalTransform.m14];
	output = [output stringByAppendingFormat:@"finalTransform.m21 = %0.4f;\n", finalTransform.m21];
	output = [output stringByAppendingFormat:@"finalTransform.m22 = %0.4f;\n", finalTransform.m22];
	output = [output stringByAppendingFormat:@"finalTransform.m23 = %0.4f;\n", finalTransform.m23];
	output = [output stringByAppendingFormat:@"finalTransform.m24 = %0.4f;\n", finalTransform.m24];
	output = [output stringByAppendingFormat:@"finalTransform.m31 = %0.4f;\n", finalTransform.m31];
	output = [output stringByAppendingFormat:@"finalTransform.m32 = %0.4f;\n", finalTransform.m32];
	output = [output stringByAppendingFormat:@"finalTransform.m33 = %0.4f;\n", finalTransform.m33];
	output = [output stringByAppendingFormat:@"finalTransform.m34 = %0.4f;\n", finalTransform.m34];
	output = [output stringByAppendingFormat:@"finalTransform.m41 = %0.4f;\n", finalTransform.m41];
	output = [output stringByAppendingFormat:@"finalTransform.m42 = %0.4f;\n", finalTransform.m42];
	output = [output stringByAppendingFormat:@"finalTransform.m43 = %0.4f;\n", finalTransform.m43];
	output = [output stringByAppendingFormat:@"finalTransform.m44 = %0.4f;\n", finalTransform.m44];
	
	outputView.text = output;
	[UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
		outputView.alpha = 1.0;
	} completion:^(BOOL finished){	}];
}

- (void)copyText {
	[[UIPasteboard generalPasteboard] setString:outputView.text];

	outputView.text = @"\nThe output has been copied to the iOS pasteboard.\n\nPress ⌘-c to copy it to the OSX clipboard, for pasting into xcode.\n\nClick the action button to dismiss this text view.";
	outputView.alpha = 0.0;
	
	[UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationCurveEaseOut animations:^{
		outputView.alpha = 1.0;
	} completion:^(BOOL finished){	}];
}

#pragma mark UITableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return [transformsArray count];
	if (section == 1) return [sourceArray count];
	return 0;
}
- (CGFloat)	 tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 60; }
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { return FALSE; }
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {	return TRUE; }
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { return UITableViewCellEditingStyleNone; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TransformifierCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TransformifierCell class]) forIndexPath:indexPath];
	cell.delegate = self;
	cell.enabled = (indexPath.section == 0);
	
	NSMutableArray *array = (indexPath.section == 0)? transformsArray : sourceArray;
	cell.transformData = [array objectAtIndex:indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	if (sourceIndexPath.section == destinationIndexPath.section) {
		NSMutableArray *array = (sourceIndexPath.section == 0)? transformsArray : sourceArray;
		
		NSNumber *tmp = [array objectAtIndex:sourceIndexPath.row];
		[array removeObjectAtIndex:sourceIndexPath.row];
		[array insertObject:tmp atIndex:destinationIndexPath.row];
	} else {
		if (destinationIndexPath.section == 0) [transformsArray insertObject:[NSMutableDictionary dictionaryWithDictionary:[sourceArray objectAtIndex:sourceIndexPath.row]] atIndex:destinationIndexPath.row];
		if (destinationIndexPath.section == 1) [transformsArray removeObjectAtIndex:sourceIndexPath.row];
	}
	
	[table reloadData];
	[self.view bringSubviewToFront:toolbar];
	[self.view bringSubviewToFront:outputView];
}

@end



@interface TransformifierCell()

	@property (nonatomic, strong) UILabel	*actionLabel;
	@property (nonatomic, strong) UILabel	*valueLabel;

@end


@implementation TransformifierCell

@synthesize delegate, actionLabel, valueLabel, slider, axisChooser, transformType, transformData, enabled;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
	
		self.actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 85, 25)];
		actionLabel.font = [UIFont systemFontOfSize:13];
		actionLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:actionLabel];
	
		self.axisChooser = [[UISegmentedControl alloc] initWithItems:@[@"X", @"Y", @"Z"]];
		axisChooser.frame = CGRectMake(95, 4, 75, 25);
		axisChooser.tintColor = [UIColor lightGrayColor];
		axisChooser.segmentedControlStyle = UISegmentedControlStyleBar;
		[self.contentView addSubview:axisChooser];
		
		self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(175, 2, 45, 25)];
		valueLabel.font = [UIFont systemFontOfSize:13];
		valueLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:valueLabel];
		
		self.slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 35, 200, 20)];
		[self.contentView addSubview:slider];

		[axisChooser addTarget:self	action:@selector(setAxisIndex)  forControlEvents:UIControlEventValueChanged];
		[slider		 addTarget:self	action:@selector(setValueLabel) forControlEvents:UIControlEventValueChanged];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	int tableWidth = self.contentView.frame.size.width;
	slider.frame = CGRectMake(slider.frame.origin.x, slider.frame.origin.y, tableWidth - 15, slider.frame.size.height);
	self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
}

- (void)setTransformData:(NSMutableDictionary *)dataDict {

	transformData = dataDict;
	self.transformType = [[transformData valueForKey:@"type"] intValue];
	
	switch (transformType) {
		case transformTypeRotate: {
			slider.minimumValue = -180;
			slider.maximumValue =  180;
			actionLabel.text = @"Rotate around";
			break;
		} case transformTypeTranslate: {
			slider.minimumValue = -50;
			slider.maximumValue =  50;
			actionLabel.text = @"Translate by";
			break;
		} case transformTypeScale: {
			slider.minimumValue =   0;
			slider.maximumValue = 500;
			actionLabel.text = @"Scale by";
			break;
		} case transformTypeSkew: {
			slider.minimumValue = -100;
			slider.maximumValue = 100;
			actionLabel.text = @"Skew around";
			break;
		} case transformTypePerspective: {
			slider.minimumValue = -5;
			slider.maximumValue = 5;
			actionLabel.text = @"Perspective";
			break;
		}
	}
	
	slider.value = [[transformData valueForKey:@"value"] floatValue];
	axisChooser.selectedSegmentIndex = [[transformData valueForKey:@"axisIndex"] intValue];
	axisChooser.enabled = (transformType != transformTypePerspective) * self.enabled;

	[self setValueLabel];
}

- (void)setEnabled:(BOOL)value {
	enabled = value;
	actionLabel.enabled = valueLabel.enabled = axisChooser.enabled = slider.enabled = enabled;
}

- (void)setAxisIndex {
	[transformData setValue:[NSNumber numberWithInt:axisChooser.selectedSegmentIndex] forKey:@"axisIndex"];
	[delegate applyTransform];
}

- (void)setValueLabel {
	[transformData setValue:[NSNumber numberWithFloat:slider.value] forKey:@"value"];

	NSString *unit = @"";
	switch (transformType) {
		case transformTypeRotate:		{ unit = @"°";	break;	}
		case transformTypeTranslate:	{ unit = @"pt";	break;	}
		case transformTypeScale:		{ unit = @"%";	break;	}
		case transformTypeSkew:			{ unit = @"%";	break;	}
		case transformTypePerspective:	{ unit = @"%";	break;	}
	}
		
	valueLabel.text = [NSString stringWithFormat:@"%0.1f%@", slider.value, unit];
	[delegate applyTransform];
}


@end

