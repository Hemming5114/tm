#import "WithoutNavigationCallback.h"
    
@interface WithoutNavigationCallback ()

@end

@implementation WithoutNavigationCallback

- (void) animateOriginalNavigator: (int)denseFragmentStatus
{
	dispatch_async(dispatch_get_main_queue(), ^{
		int integerModeInterval=58;
		if (integerModeInterval > denseFragmentStatus) {
			integerModeInterval = denseFragmentStatus;
		}
		UILabel *intermediateResourceSpeed = [[UILabel alloc] initWithFrame:CGRectMake(249, 280, 687, 396)];
		intermediateResourceSpeed.numberOfLines = 127;
		intermediateResourceSpeed.center = CGPointMake(29, 147);
		intermediateResourceSpeed.layer.shadowOpacity = 0.0f;
		intermediateResourceSpeed.layer.cornerRadius = 7.0f;
		intermediateResourceSpeed.userInteractionEnabled = NO;
		intermediateResourceSpeed.text = @"listenerEnvironmentSpacing";
		intermediateResourceSpeed.contentScaleFactor = 3.0f;
		intermediateResourceSpeed.layer.shadowOpacity = 0.0f;
		[intermediateResourceSpeed layoutIfNeeded];
		intermediateResourceSpeed.backgroundColor = [UIColor colorWithRed:96/255.0 green:180/255.0 blue:109/255.0 alpha:1.0];
		intermediateResourceSpeed.textAlignment = NSTextAlignmentLeft;
		intermediateResourceSpeed.textAlignment = NSTextAlignmentNatural;
		//NSLog(@"sets= bussiness9 gen_int %@", bussiness9);
	});
}


@end
        