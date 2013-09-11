//
//  ShowsViewController.h
//  CelebrityApp
//
//  Created by Muhammad Jabbar on 8/1/13.
//  Copyright (c) 2013 Muhammad Jabbar. All rights reserved.
//

#import "ShowsService.h"

@interface ShowsViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITableView *listingTableView;
@property (nonatomic,strong) ShowsService *showsService;
@property (nonatomic,strong) NSMutableArray *shows;



@end
