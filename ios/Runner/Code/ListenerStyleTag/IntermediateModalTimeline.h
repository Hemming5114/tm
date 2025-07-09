#import "InactiveFrameObserver.h"
#import "CrudeRadioArray.h"
#import "PriorityAdapterPosition.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IntermediateModalTimeline : NSObject


- (void) deactivateCurrentBloc;

- (void) afterBinaryDelivery;

@end

NS_ASSUME_NONNULL_END
        