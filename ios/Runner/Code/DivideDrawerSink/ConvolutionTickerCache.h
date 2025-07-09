#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConvolutionTickerCache : NSObject

@property (nonatomic) NSString * groupStateTint;

+ (instancetype) convolutionTickercacheWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) uniqueResourceTag;

- (NSMutableDictionary *) futureByState;

- (int) constChannelName;

- (NSMutableSet *) lazyRouteFeedback;

- (NSMutableArray *) imperativeMasterRotation;

@end

NS_ASSUME_NONNULL_END
        