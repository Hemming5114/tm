#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderResourceInstance : NSObject

@property (nonatomic) int composableBehaviorOrientation;

+ (instancetype) renderresourceInstanceWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) presenterShapeTint;

- (NSMutableDictionary *) dependencyAmongAdapter;

- (int) nodeVisitorOffset;

- (NSMutableSet *) directStatefulFrequency;

- (NSMutableArray *) dropdownbuttonPlatformAppearance;

@end

NS_ASSUME_NONNULL_END
        