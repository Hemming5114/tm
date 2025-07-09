#import "OutShaderData.h"
#import "DetachMaterialCache.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackwardReactiveBatch : NSObject


- (void) saveDiscardedOffset;

- (void) poolDynamicScaffold;

@end

NS_ASSUME_NONNULL_END
        