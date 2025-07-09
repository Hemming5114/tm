#import "WebLayerAdapter.h"
#import "DiscardedSegueInterface.h"
#import "AlertCompleterContainer.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultiDeclarativeChapter : NSObject


- (void) resolveLazyStream;

- (void) instantiateDisabledCompleter;

@end

NS_ASSUME_NONNULL_END
        