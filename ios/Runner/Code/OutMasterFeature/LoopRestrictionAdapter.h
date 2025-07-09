#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoopRestrictionAdapter : NSObject

@property (nonatomic) int visibleReferenceCount;

+ (instancetype) loopRestrictionAdapterWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) asynchronousSizeTheme;

- (NSMutableDictionary *) tabviewFacadeOpacity;

- (int) requestInsideSingleton;

- (NSMutableSet *) serviceAmongParameter;

- (NSMutableArray *) threadStructureStyle;

@end

NS_ASSUME_NONNULL_END
        