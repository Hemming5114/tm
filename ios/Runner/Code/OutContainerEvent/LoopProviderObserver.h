#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoopProviderObserver : NSObject

@property (nonatomic) NSMutableDictionary * viewTempleTail;

+ (instancetype) loopProviderObserverWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) transitionCompositeState;

- (NSMutableDictionary *) captionSinceVisitor;

- (int) modelCycleState;

- (NSMutableSet *) promiseAgainstCycle;

- (NSMutableArray *) timerMethodVisibility;

@end

NS_ASSUME_NONNULL_END
        