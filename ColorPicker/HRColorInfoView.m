/*-
 * Copyright (c) 2011 Ryota Hayashi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */


#import "HRColorInfoView.h"
#import "HRColorPickerView.h"

const CGFloat kHRColorInfoViewLabelHeight = 18.;
const CGFloat kHRColorInfoViewCornerRadius = 3.;

@interface HRColorInfoView () {
    UIColor *_color;
}
@end

@implementation HRColorInfoView {
    UILabel *_hexColorLabel;
    CALayer *_borderLayer;
}

@synthesize color = _color;

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self.backgroundColor = [UIColor clearColor];
    _hexColorLabel = [[UILabel alloc] init];
    _hexColorLabel.backgroundColor = [UIColor clearColor];
    _hexColorLabel.font = [UIFont systemFontOfSize:12];
    _hexColorLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    _hexColorLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_hexColorLabel];

    _borderLayer = [[CALayer alloc] initWithLayer:self.layer];
    _borderLayer.cornerRadius = kHRColorInfoViewCornerRadius;
    _borderLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    _borderLayer.borderWidth = 1.f / [[UIScreen mainScreen] scale];
    [self.layer addSublayer:_borderLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _hexColorLabel.frame = CGRectMake(
            0,
            CGRectGetHeight(self.frame) - kHRColorInfoViewLabelHeight,
            CGRectGetWidth(self.frame),
            kHRColorInfoViewLabelHeight);

    _borderLayer.frame = (CGRect) {.origin = CGPointZero, .size = self.frame.size};
}

- (void)setColor:(UIColor *)color {
    _color = color;
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    _hexColorLabel.text = [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                           lroundf(r * 255),
                           lroundf(g * 255),
                           lroundf(b * 255)];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect colorRect = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect) - kHRColorInfoViewLabelHeight);

    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect:colorRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4, 4)];
    [rectanglePath closePath];
    [self.color setFill];
    [rectanglePath fill];
}

- (UIView *)viewForLastBaselineLayout {
    return _hexColorLabel;
}

- (UIView *)viewForFirstBaselineLayout {
    return _hexColorLabel;
}

- (unsigned int)intFromHexString:(NSString *)hexStr {
  unsigned int hexInt = 0;

  // Create scanner
  NSScanner *scanner = [NSScanner scannerWithString:hexStr];

  // Tell scanner to skip the # character
  [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];

  // Scan hex value
  [scanner scanHexInt:&hexInt];

  return hexInt;
}

- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
  // Convert hex string to an integer
  unsigned int hexint = [self intFromHexString:hexStr];

  // Create a color object, specifying alpha as well
  UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
    blue:((CGFloat) (hexint & 0xFF))/255
    alpha:alpha];

  return color;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    HRColorPickerView *picker = (HRColorPickerView *)self.superview;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Hex Value" message:NULL preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont fontWithName:@"Courier" size:textField.font.pointSize];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *text = alert.textFields.firstObject.text;
        
        if (!text) {
            return;
        }
        
        picker.color = [self getUIColorObjectFromHexString:text alpha:1];
        
    }]];
    
    UIViewController *vc = (UIViewController *)picker.nextResponder.nextResponder;
    [vc presentViewController:alert animated:YES completion:NULL];
}

@end

