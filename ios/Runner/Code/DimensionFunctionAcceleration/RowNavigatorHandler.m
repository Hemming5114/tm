#import "RowNavigatorHandler.h"
    
@interface RowNavigatorHandler ()

@end

@implementation RowNavigatorHandler

- (void) startDescriptorAndOccasion: (NSMutableDictionary *)fusedMenuAcceleration
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSInteger permanentGroupMode = fusedMenuAcceleration.count;
		UITableView *delicateRowLeft = [[UITableView alloc] init];
		[delicateRowLeft setDelegate:self];
		[delicateRowLeft setDataSource:self];
		[delicateRowLeft setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
		[delicateRowLeft setRowHeight:47];
		NSString *petForScope = @"CellIdentifier";
		[delicateRowLeft registerClass:[UITableViewCell class] forCellReuseIdentifier:petForScope];
		UIRefreshControl *cosineFormRotation = [[UIRefreshControl alloc] init];
		[cosineFormRotation addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
		[delicateRowLeft setRefreshControl:cosineFormRotation];
		if (permanentGroupMode > 4) {
			// 当字典元素较多时，添加分页控件
			UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
			pageControl.numberOfPages = permanentGroupMode / 10 + 1;
			pageControl.currentPage = 0;
			[pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
		}
		//NSLog(@"Business18 gen_dic with count: %d%@", permanentGroupMode);
	});
}


@end
        