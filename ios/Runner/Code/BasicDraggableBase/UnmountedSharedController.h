#import "DiffablePublisherTarget.h"
#import "SemanticAllocatorHandler.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnmountedSharedController : NSObject


- (void) cacheStatefulInteractor;

- (void) unmountNextClipper;

@end

NS_ASSUME_NONNULL_END
        