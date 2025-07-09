#import "ActiveScopeImplement.h"
#import "TransformSpineCache.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ElasticThreadStack : NSObject


- (void) mitigateBlocNearFrame;

- (void) propagateStandaloneLabel;

@end

NS_ASSUME_NONNULL_END
        