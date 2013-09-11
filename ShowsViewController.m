//
//  ShowsViewController.m
//  CelebrityApp
//
//  Created by Muhammad Jabbar on 8/1/13.
//  Copyright (c) 2013 Muhammad Jabbar. All rights reserved.
//

#import "ShowsViewController.h"
#import "DetailViewController.h"
#import "ShowCell.h"
#import "ShowsService.h"
#import "Show.h"

@interface ShowsViewController ()

@end

@implementation ShowsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)getAllShows{
    [self showProgressForView:self.view WithMessage:self.progressMessage];
    if(_showsService==nil)
        _showsService=[[ShowsService alloc] init];
    [_showsService getAllShows:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.listingTableView setBackgroundView:nil];
    self.navigationItem.hidesBackButton = YES;
    _shows=[NSMutableArray new];
    self.progressMessage =@"Loading...";
}
-(void)viewWillAppear:(BOOL)animated{
    [self getAllShows];
    self.progressMessage =@"Updating...";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 90;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_shows count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"ShowCell";
    
    ShowCell *cell = (ShowCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ShowCell" owner:nil options:nil] objectAtIndex:0];
    }
    Show *show=[_shows objectAtIndex:indexPath.row];
    cell.dateLabel.text = show.showDate;
    cell.showVenu.text = show.showVenu;
    cell.showTitle.text = show.showTitle;
    cell.showsDesc.text=show.showDescription;
    
    cell.showImage.image = nil;
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *fileName = [NSString stringWithFormat:@"show_%@.png",show.showId];
    NSString *filePath = [Utils documentsPathForFileName:fileName];
    if ([fileManger fileExistsAtPath:filePath]) {
        [cell.showImage setImage:[UIImage imageWithContentsOfFile:filePath]];
    }else{
        [cell.spinner startAnimating];
        [self dowloadImage:show.showImage forCell:cell saveAtPath:filePath];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Show *selectedShow = [_shows objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc]init];
    detailVC.title  = @"Show Detail";
    detailVC.detailText = selectedShow.showDescription;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - ServiceDelegate
- (void) service:(BaseService*)service reponseRecieved:(id)object andStatusInfo:(NSDictionary *)statusInfo{
    
    [super service:service reponseRecieved:object andStatusInfo:statusInfo];
    NSArray *result = (NSArray *)object;
    _shows=[NSMutableArray arrayWithArray:result];
    [self.listingTableView reloadData];
    
}
-(void)service:(BaseService *)service failedWithStatusInfo:(NSDictionary *)statusInfo{

    [super service:service failedWithStatusInfo:statusInfo];

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
