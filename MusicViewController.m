//
//  MusicViewController.m
//  CelebrityApp
//
//  Created by Muhammad Jabbar on 8/1/13.
//  Copyright (c) 2013 Muhammad Jabbar. All rights reserved.
//

#import "MusicViewController.h"
#import "VideoPlayerViewController.h"
#import "NSString+HTML.h"
#import "VideoCell.h"
#import "Song.h"
@interface MusicViewController ()

@end

@implementation MusicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.progressMessage =@"Loading...";
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getAllSongs];
    self.progressMessage =@"Updating...";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 112;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _songs.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"VideoCell";
    VideoCell *cell = (VideoCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"VideoCell" owner:nil options:nil] objectAtIndex:0];
        [cell.btnPurchase setHidden:NO];
        [cell.btnPurchase addTarget:self action:@selector(btnPurchaseTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    Song *song = [_songs objectAtIndex:indexPath.row];
    cell.lblTitle.text = song.songTitle;
    cell.lblDuration.text = [song.songDescription stringByConvertingHTMLToPlainText];
    cell.btnPurchase.tag = indexPath.row;
    cell.imgView.image = nil;
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *fileName = [NSString stringWithFormat:@"music_%@.png",song.songId];
    NSString *filePath = [Utils documentsPathForFileName:fileName];
    if ([fileManger fileExistsAtPath:filePath]) {
        [cell.imgView setImage:[UIImage imageWithContentsOfFile:filePath]];
    }else{
        [self dowloadImage:song.songThumbURL forCell:cell saveAtPath:filePath];
        [cell.spinner startAnimating];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Song *selectedSong = [_songs objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:selectedSong.songItunesURL]];
}

#pragma mark - ServiceDelegate
- (void) service:(BaseService*)service reponseRecieved:(id)object andStatusInfo:(NSDictionary *)statusInfo{
    
    [super service:service reponseRecieved:object andStatusInfo:statusInfo];
    NSArray *result = (NSArray *)object;
    _songs =[NSMutableArray arrayWithArray:result];
    [self.listingTableView reloadData];
    
}
-(void)service:(BaseService *)service failedWithStatusInfo:(NSDictionary *)statusInfo{
    
    [super service:service failedWithStatusInfo:statusInfo];
}

#pragma Mark Custom Methods
-(void)getAllSongs{
    [self showProgressForView:self.view WithMessage:self.progressMessage];
    if (_musicService == nil)
        _musicService  = [[MusicService alloc]init];
    
    [_musicService getSongsInfo:self];
}
- (void)dowloadImage:(NSString*)imageURL forCell:(VideoCell*)cell saveAtPath:(NSString*)savePath {
    
    NSLog(@"Getting %@...", imageURL);
    imageURL = [NSString stringWithFormat:@"%@%@",BASE_URL,imageURL];
    NSURL *sourceURL = [NSURL URLWithString:imageURL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:sourceURL];
    [request setCompletionBlock:^{
        //        NSLog(@"Zip file downloaded.");
        NSData *data = [request responseData];
        UIImage *image = [UIImage imageWithData:data];
        [cell.imgView setImage:image];
        [cell.spinner stopAnimating];
        [data writeToFile:savePath atomically:YES];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error downloading zip file: %@", error.localizedDescription);
        [cell.spinner stopAnimating];
    }];
    [request startAsynchronous];
}

-(void)btnPurchaseTapped:(id)sender{
    UIButton *btn = (UIButton*)sender;
    Song *song = [_songs objectAtIndex:btn.tag];
    NSLog(@"Itunes link for this song is %@",song.songItunesURL);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:song.songItunesURL]];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
