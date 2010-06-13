#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface MonomeButton : UIButton {
    UIColor *_highColor;
    UIColor *_lowColor;
    
    CAGradientLayer *gradientLayer;
}

@property (assign) UIColor *_highColor;
@property (assign) UIColor *_lowColor;
@property (nonatomic, retain) CAGradientLayer *gradientLayer;

- (void)setHighColor:(UIColor*)color;
- (void)setLowColor:(UIColor*)color;


@end
