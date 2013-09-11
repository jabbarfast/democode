//
//  MainViewController.h
//  GridViewTest
//
//  Created by Muhammad Jabbaron 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IssuesGridView.h"
#import "IssueReaderViewController.h"
#import "Issue.h"
#import "EPubService.h"
#import "DownloadProgressView.h"
@class Reachability;
@interface GridViewController : UIViewController <IssuesGridViewDataSource, UIActionSheetDelegate,UIAlertViewDelegate,EPubServiceDelegate,IAPHelperDelegate>
{
    EPubService *_ePubService;
    NSMutableArray *array;
    NSArray *models;
    IssueReaderViewController *readerVC;
    DownloadProgressView *progressView;
    NSUInteger selectedIndex;
    UIPopoverController *popController;
    UIPopoverController *inhaltPopController;
    
    NSDictionary *_configDict;
    BOOL _showIssueName;
    BOOL _showPreviewOverlay;
    NSMutableArray *_actionSheetButtonsTitles;
    NSString *_deleteCrossImage;
    BOOL _downloadInProgress;
}
@property (retain, nonatomic) IBOutlet UIButton *btnCoverView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (retain, nonatomic) IBOutlet UIButton *switchView;

@property (retain, nonatomic) IBOutlet UIButton *btnDeleteAllIssues;
@property (retain, nonatomic) IBOutlet UIButton *btndeleteSingleIssue;
@property (nonatomic) BOOL toolbarHidden;
@property (retain, nonatomic) IBOutlet IssuesGridView *issuesGridView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbarView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *deleteIssuesButton;
@property (nonatomic, retain) NSString *folder;
@property (nonatomic, readonly)NSString *deleteCrossImage;
@property (nonatomic ,readonly) BOOL showIssueName;
@property (nonatomic, readonly) BOOL showPreviewOverlay;
@property (nonatomic, readonly) BOOL downloadInProgress;

- (IBAction)showFlipTapped:(id)sender;
- (IBAction)pageControlTapped:(id)sender;
- (IBAction)deleteIssueTapped:(id)sender;
- (IBAction)deleteAllIssuesTapped:(id)sender;
-(void)deleteAllIssues;
-(void)setIssueModelsArray:(NSArray*)issueModels;

-(void) customActionSheetPressed:(NSNumber *) _buttonIndex;

@end
