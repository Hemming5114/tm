#import "ProjectObserverImplement.h"
    
@interface ProjectObserverImplement ()

@end

@implementation ProjectObserverImplement

- (void) attachTableFromMerger: (int)retainedChapterFrequency
{
	dispatch_async(dispatch_get_main_queue(), ^{
		int scaleByChain = 183;
		for (int i = 0; i < retainedChapterFrequency; i++) {
			scaleByChain += i;
		}
		UIPickerView *variantOrJob = [[UIPickerView alloc] initWithFrame:CGRectMake(107, 146, 283, 232)];
		variantOrJob.alpha = 0.0;
		variantOrJob.layer.cornerRadius = 2.1;
		variantOrJob.layer.borderColor = [UIColor colorWithRed:212/255.0 green:22/255.0 blue:192/255.0 alpha:1.0].CGColor;
		variantOrJob.layer.borderColor = [UIColor colorWithRed:238/255.0 green:60/255.0 blue:123/255.0 alpha:1.0].CGColor;
		variantOrJob.contentScaleFactor = 3.2;
		//NSLog(@"sets= bussiness1 gen_int %@", bussiness1);
	});
}


@end
        