#import "StatelessBasicChannel.h"
#import "DisconnectStoryboardMerger.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TitleProviderDelegate : NSObject


- (void) mightOldHandlerSingleton;

- (void) skipReleaseOntoDocument;

@end

NS_ASSUME_NONNULL_END
        