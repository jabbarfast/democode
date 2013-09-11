//
//  MusicViewController.h
//  CelebrityApp
//
//  Created by Muhammad Jabbar on 8/1/13.
//  Copyright (c) 2013 Muhammad Jabbar. All rights reserved.
//

#import "MusicService.h"
@interface MusicViewController :BaseViewController
@property (strong, nonatomic) IBOutlet UITableView *listingTableView;
@property (nonatomic, strong) NSArray *songs;
@property (strong, nonatomic) MusicService *musicService;

@end
