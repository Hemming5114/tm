#import "FromSensorController.h"
#import "OnSampleImage.h"
#import "ReleaseStampCreator.h"
#import "AspectChartHelper.h"
#import "ObserverNavigatorOwner.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResponsiveVolumeImplement : NSObject


- (void) persistThroughWorkflowCommand;

- (void) reconcileNativeAxis;

@end

NS_ASSUME_NONNULL_END
        