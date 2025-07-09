#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HandlerRestrictionHelper : NSObject

@property (nonatomic) NSMutableSet * serviceCommandDuration;

+ (instancetype) handlerRestrictionhelperWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) unactivatedMobileMode;

- (NSMutableDictionary *) alphaOrScope;

- (int) sequentialFrameFeedback;

- (NSMutableSet *) delegateWithoutOperation;

- (NSMutableArray *) scaffoldAsScope;

@end

NS_ASSUME_NONNULL_END
        