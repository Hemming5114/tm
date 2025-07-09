#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DecodeStepBuilder : NSObject

@property (nonatomic) NSMutableArray * referenceCommandScale;

+ (instancetype) decodeStepBuilderWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) storageParamName;

- (NSMutableDictionary *) catalystWithAdapter;

- (int) synchronousAccessoryTint;

- (NSMutableSet *) vectorVisitorDepth;

- (NSMutableArray *) keySceneRotation;

@end

NS_ASSUME_NONNULL_END
        