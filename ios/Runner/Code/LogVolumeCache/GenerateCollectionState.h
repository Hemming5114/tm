#import "MobileJoinerProtocol.h"
#import "SinkTimeList.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GenerateCollectionState : NSObject


- (void) discoverAfterInjectionTask;

- (void) scheduleNextSink;

@end

NS_ASSUME_NONNULL_END
        