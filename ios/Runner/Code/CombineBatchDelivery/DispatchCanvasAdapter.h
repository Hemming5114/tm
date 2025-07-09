#import "MediocreUnactivatedCapsule.h"
#import "ExplicitTouchLatency.h"
#import "PartitionImageDelegate.h"
#import "SanitizeImageInfrastructure.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DispatchCanvasAdapter : NSObject


- (void) serializeIntermediateOffset;

- (void) registerObserverChannel;

@end

NS_ASSUME_NONNULL_END
        