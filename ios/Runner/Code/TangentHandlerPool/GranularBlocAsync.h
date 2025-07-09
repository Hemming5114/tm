#import "StandaloneSchedulerGroup.h"
#import "GlobalRouteTimeline.h"
#import "AwaitCatalystVertex.h"
#import "HierarchicalStepConstraint.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GranularBlocAsync : NSObject


- (void) connectControllerOrCallback;

- (void) buildMemberBySubscription;

@end

NS_ASSUME_NONNULL_END
        