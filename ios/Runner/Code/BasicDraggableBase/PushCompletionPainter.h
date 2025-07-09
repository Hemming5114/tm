#import "RobustCubeBase.h"
#import "FlexibleCoordinatorDelegate.h"
#import "OnSceneSorter.h"
#import "SymmetricAnimationAnalyzer.h"
#import "MaterialRadiusStack.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PushCompletionPainter : NSObject


- (void) processWithinCallbackShape;

- (void) cancelBehaviorWithRenderer;

@end

NS_ASSUME_NONNULL_END
        