#import "ShowStatefulAnimatedcontainer.h"
    
@interface ShowStatefulAnimatedcontainer ()

@end

@implementation ShowStatefulAnimatedcontainer

- (void) mountAxisWithoutCluster: (NSString *)futureOrValue
{
	dispatch_async(dispatch_get_main_queue(), ^{
		CALayer * frameOfDecorator = [[CALayer alloc] init];
		frameOfDecorator.name = futureOrValue;
		frameOfDecorator.bounds = CGRectMake(389, 132, 691, 629);
		frameOfDecorator.borderWidth = 691;
		frameOfDecorator.backgroundColor = [UIColor greenColor].CGColor;
		frameOfDecorator.borderColor = [UIColor orangeColor].CGColor;
		//NSLog(@"sets= bussiness8 gen_str %@", bussiness8);
	});
}


@end
        