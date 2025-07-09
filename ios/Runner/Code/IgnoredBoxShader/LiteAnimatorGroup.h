#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiteAnimatorGroup : NSObject

@property (nonatomic) NSString * visibleRequestContrast;

@property (nonatomic) NSMutableDictionary * constraintLikeSingleton;

@property (nonatomic) int tappableBufferPosition;

+ (instancetype) liteAnimatorGroupWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) ignoredNotificationCenter;

- (NSMutableDictionary *) localGraphOpacity;

- (int) titleCompositeOrientation;

- (NSMutableSet *) stackByStyle;

- (NSMutableArray *) mediaqueryStyleSize;

@end

NS_ASSUME_NONNULL_END
        