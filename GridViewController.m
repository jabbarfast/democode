//
//  MainViewController.m
//  GridViewTest
//
//  Created by Muhammad Jabbar on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"
#import "Issue.h"
#import "ReaderDocument.h"
#import "IssueReaderViewController.h"
#import "clsGlobalMessage.h"
#import "clsGlobalKeys.h"
#import "clsGlobal.h"
#import "InHaltPopOverViewCtrl.h"
#import "HomeViewController.h"
#import "ViewControllerWithButtons.h"
#import "Util.h"
#import "LappKabelAppDelegate.h"
#import "Constants.h"
#import "IAPHelper.h"
@interface GridViewController(Private)
- (void)reloadIssues;
-(void)initilizeConfigDictionary;
- (void)setFrames;
@end

@implementation GridViewController
@synthesize deleteIssuesButton;
@synthesize issuesGridView;
@synthesize pageControl;
@synthesize toolbarView;
@synthesize btnCoverView;
@synthesize backgroundImage;
@synthesize switchView;
@synthesize btnDeleteAllIssues;
@synthesize btndeleteSingleIssue;
@synthesize toolbarHidden;
@synthesize folder;
@synthesize showIssueName = _showIssueName;
@synthesize showPreviewOverlay = _showPreviewOverlay;
@synthesize deleteCrossImage = _deleteCrossImage;
@synthesize downloadInProgress = _downloadInProgress;

- (void)dealloc {
      _ePubService.delegate = nil;
    [_ePubService release];
    [issuesGridView release];
    [pageControl release];
    [toolbarView release];
    [backgroundImage release];
    [deleteIssuesButton release];
    [btnDeleteAllIssues release];
    [btndeleteSingleIssue release];
    [_deleteCrossImage release];
    [switchView release];
    [btnCoverView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _ePubService = [[EPubService alloc]init];
        _ePubService.delegate = self;
        [self initilizeConfigDictionary];
        _showIssueName = [[_configDict valueForKey:@"ShowIssueName"] boolValue];
        _showPreviewOverlay = [[_configDict valueForKey:@"ShowPreviewOverly"] boolValue];
        _deleteCrossImage = [_configDict valueForKey:@"DeleteCrossImage"];
        _actionSheetButtonsTitles = [[NSMutableArray alloc]init];
        

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)setIssueModelsArray:(NSArray*)issueModels{
    models = issueModels;
    
}


- (NSUInteger) numberOfIssuesForGridView:(IssuesGridView *)gridView{
    return [array count];
}
- (NSString *) gridView:(IssuesGridView *)gridView 
    textForIssueAtIndex:(NSUInteger)index{
    
    Issue * i = [array objectAtIndex:index];
    NSLog(@"%@",i.displayName);
    return [i displayName];
    
}

- (BOOL) gridView:(IssuesGridView *)gridView 
issueIsPreviewAtIndex:(NSUInteger)index{
    Issue * i = [array objectAtIndex:index];
    return [i previewed] && ![i purchased];
    
}

- (NSString *) gridView:(IssuesGridView *)gridView 
    pathForImageAtIndex:(NSUInteger)index{
    Issue * i = [array objectAtIndex:index];
    return i.coverImagePath;
}

- (void)gridView:(IssuesGridView *)gridView
willDeleteIssueAtIndex:(NSUInteger)index{
    
}

- (void)gridView:(IssuesGridView *)gridView
 didDeleteIssueAtIndex:(NSUInteger)index{
     LappKabelAppDelegate *appDelegate = (LappKabelAppDelegate*)[UIApplication sharedApplication].delegate;
    Issue*i = [array objectAtIndex:index];
    [i deleteIssue];
    [appDelegate deleteBookmarks:i.contentFilename];
    [appDelegate deleteNotes:i.contentFilename];
    [appDelegate deleteArticlesInfo:i.contentFilename];
    [appDelegate deleteWeblinks:i.contentFilename];
    [Util writAllIssuesDataToPlist:array];
 
   
    if (appDelegate.isOffline) {
        NSMutableArray *arr = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for(Issue *i in array){
            if (i.previewed && !(i.deleted)) {
                [arr addObject:i];
            }
           
        }
        HomeViewController  *homeVC = (HomeViewController*)self.parentViewController;
        [homeVC updateIssuesArray:arr];
    }
    [self reloadIssues];
    [issuesGridView reloadData];
}



- (void)gridView:(IssuesGridView *)gridView
didSelectIssueWithIndex:(NSUInteger)index{
    selectedIndex = index;
    [self customActionSheetPressed:[NSNumber numberWithInteger:index]];
}

-(BOOL)gridView:(IssuesGridView *)gridView issueIsPurchasedAtIndex:(NSUInteger)index{
    Issue* issue = [array objectAtIndex:index];
    return issue.purchased;
}

-(BOOL)gridView:(IssuesGridView *)gridView 
issueIsDeletedAtIndex:(NSUInteger)index{
    Issue* issue = [array objectAtIndex:index];
    return issue.deleted;
}


-(BOOL)gridView:(IssuesGridView *)gridView 
issueIsPreviewedAtIndex:(NSUInteger)index {
    Issue* issue = [array objectAtIndex:index];
    return issue.previewed;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.hidden = NO;
    [self reloadIssues];
    [issuesGridView reloadData];
    [self.view setFrame:self.view.superview.bounds];
    [pageControl setHidden:NO];
    [self.view bringSubviewToFront:pageControl];
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
    [pageControl setNumberOfPages:ceil([array count]/4.0)];        
    }else{
            [pageControl setNumberOfPages:ceil([array count]/6.0)];
    }
    [self.view bringSubviewToFront:pageControl];
    NSLog(@"btn Frame is %@",NSStringFromCGRect(btnCoverView.frame));

}

-(void) customActionSheetPressed:(NSNumber *) _buttonIndex{
    
    [popController dismissPopoverAnimated:NO];
    int issueIndex = selectedIndex;
    //int buttonIndex = [_buttonIndex intValue];
    
    NSUInteger index = 0;
    for(Issue *i in array){
        Issue *j = [models objectAtIndex:issueIndex];
        
        if ([i.name isEqualToString:j.name]) {
            break;
        }
        index++;
    }
    Issue* issue= [array objectAtIndex:issueIndex];
    if (issue.purchased) {
        folder = @"private";
    }else{
        folder = @"public";
    }
    if (!((issue.previewed || issue.purchased) && !issue.deleted)) {
           
        UIAlertView *purchaseAlert = [[[UIAlertView alloc] initWithTitle:@"Info" 
                                                                 message:[NSString stringWithFormat:[Util localizedStringForKey:@"MessagePreviewSize"],issue.displayName,issue.publicFolderSize]
                                                                delegate:self 
                                                       cancelButtonTitle:[Util localizedStringForKey:@"StringCancel"] 
                                                       otherButtonTitles:@"OK", nil] autorelease];
        
        purchaseAlert.tag = PURCHASEALERTTAG; 
        [purchaseAlert show];
    }
    else {
		NSString *issueName = issue.contentFilename;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
		NSString *directoryPath = [NSString stringWithFormat:@"%@/%@/%@/%@",[paths objectAtIndex:0], issueName,folder,@"iPad/issue"];
        
        NSString *filePath = nil;
        if ([folder isEqualToString:@"public"]) {
            filePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"LK_%@.pdf",issueName]];
        }else{
            filePath =  [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"BP_%@.pdf",issueName]];
        }
        
		ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:filePath password:nil];
		
		if (document != nil) // Must have a valid ReaderDocument object in order to proceed
		{
            if (readerVC != nil) {
                [readerVC removeFromParentViewController];
                [readerVC release];
            }
            
            readerVC =[[IssueReaderViewController alloc] initWithNibName:@"IssueReaderViewController" bundle:nil];
            [readerVC setDocument:document];
            [readerVC setIssueName:issueName];
            [readerVC setDisplayName:issue.displayName];
            [readerVC setFolder:folder];
            
            HomeViewController  *homeVC = (HomeViewController*)self.parentViewController;

            [self.parentViewController addChildViewController:readerVC];
            
            [self.parentViewController transitionFromViewController:self toViewController:readerVC duration:0.0 options:UIViewAnimationOptionTransitionNone animations:^{} completion:^(BOOL finished) {
                [readerVC.view setFrame:homeVC.containerView.bounds];
                
                [readerVC.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
                [readerVC didMoveToParentViewController:self.parentViewController];
            }]; 
		}
        [document release];
    }
    
}

- (void)gridView:(IssuesGridView *)gridView 
pageFlippedToIndex:(NSUInteger)index{
    
    [pageControl setCurrentPage:index];
    
}
#pragma mark - View lifecycle

- (void)reloadIssues {
    [array release];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    for(Issue *i in models){
        [arr addObject:i];
    }
    array = [[NSArray arrayWithArray:arr] retain];
    [arr release];
}

- (void) viewWillAppear:(BOOL)animated{
    self.view.hidden = YES;
    [super viewWillAppear:animated];
    

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelTransanction) name:kProductPurchaseFailedNotificationAllIssue object:nil];
    
    if ([[_configDict valueForKey:@"CanDeleteIssues"] boolValue] == NO) {
        [btndeleteSingleIssue setHidden:YES];
    }
 
    NSString * code = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([code isEqualToString:@"de"]) {
        [btndeleteSingleIssue setImage:[UIImage imageNamed:@"de_edit.png"] forState:UIControlStateNormal];
        [btnDeleteAllIssues setImage:[UIImage imageNamed:@"de_delete_all.png"] forState:UIControlStateNormal];
        
    }else {
        [btndeleteSingleIssue setImage:[UIImage imageNamed:@"en_edit.png"] forState:UIControlStateNormal];
        [btnDeleteAllIssues setImage:[UIImage imageNamed:@"en_delete_all.png"] forState:UIControlStateNormal];
    }
    
    //[self reloadIssues];
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [pageControl setNumberOfPages:ceil(array.count/6.0)];
    }else{
        [pageControl setNumberOfPages:ceil(array.count/4.0)];
    }
    [self.toolbarView setHidden:toolbarHidden];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    

    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidUnload
{
    [self setIssuesGridView:nil];
    [self setPageControl:nil];
    [self setToolbarView:nil];
    [self setBackgroundImage:nil];
    [self setDeleteIssuesButton:nil];
    [self setBtnDeleteAllIssues:nil];
    [self setBtndeleteSingleIssue:nil];
    [self setSwitchView:nil];
    [self setBtnCoverView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//	return YES;
//}

- (IBAction)showFlipTapped:(id)sender {
    self.view.hidden = YES;
    HomeViewController *controller = (HomeViewController*)self.parentViewController;
    [controller showFlip];
     //self.view.hidden = NO;
    //[self performSelector:@selector(showView) withObject:nil afterDelay:.25];
}
-(void)showView{
    self.view.hidden = NO;
}

- (IBAction)pageControlTapped:(id)sender {
    [issuesGridView flipToPageIndex:pageControl.currentPage];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [popController dismissPopoverAnimated:NO];
    [inhaltPopController dismissPopoverAnimated:NO];
    [self.toolbarView setHidden:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

    if (progressView!=nil) {
        [self setFrames];
        progressView.hidden = NO;
    }
    
    [self.issuesGridView setHidden:NO];
    [self.toolbarView setHidden:NO];
    
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [pageControl setNumberOfPages:ceil(array.count/6.0)];
    }else{
        [pageControl setNumberOfPages:ceil(array.count/4.0)];
    }

}

- (IBAction)deleteIssueTapped:(id)sender {
    
    if (_downloadInProgress) {
        return;
    }
    
    int count = 0;
    for(Issue *i in array){
        if (i.previewed && !i.deleted) {
            count = count +1;
        }
    }
    
    if (count == 0 && !issuesGridView.isEditing) {
        UIAlertView *noDownloadedIssueAlert = [[[UIAlertView alloc] initWithTitle:[Util localizedStringForKey:@"TitleNoDownloadedIssue"] message:[Util localizedStringForKey:@"MessageNoDownloadedIssue"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [noDownloadedIssueAlert show];
        return;
    }
    
    NSString * code = [[NSLocale preferredLanguages] objectAtIndex:0];
    

    if (issuesGridView.isEditing) {
        [issuesGridView setIsEditing:NO];
        if ([code isEqualToString:@"de"]) {
            [btndeleteSingleIssue setImage:[UIImage imageNamed:@"de_edit.png"] forState:UIControlStateNormal];
        }else {
            [btndeleteSingleIssue setImage:[UIImage imageNamed:@"en_edit.png"] forState:UIControlStateNormal];
        }
        [btnDeleteAllIssues setHidden:YES];

    }else{
        [issuesGridView setIsEditing:YES];
        if ([code isEqualToString:@"de"]) {
            [btndeleteSingleIssue setImage:[UIImage imageNamed:@"de_cancel.png"] forState:UIControlStateNormal];
        }else {
            [btndeleteSingleIssue setImage:[UIImage imageNamed:@"en_cancel.png"] forState:UIControlStateNormal];
        }
        [btnDeleteAllIssues setHidden:NO];

    }
    

}

- (IBAction)deleteAllIssuesTapped:(id)sender {
    int count = 0;
    for(Issue *i in array){
        if (i.previewed && !i.deleted) {
            count = count +1;
        }
    }
    if (count == 0 && issuesGridView.isEditing) {
        UIAlertView *noDownloadedIssueAlert = [[[UIAlertView alloc] initWithTitle:@"No Downloaded Issue" message:@"You have not downloaded any issue" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [noDownloadedIssueAlert show];
        return;
    }
    
    UIAlertView *deleteAllIssuesAlert = [[[UIAlertView alloc]initWithTitle:@"Info" message:[Util localizedStringForKey:@"MessageDeleteAllIssue"]
                                                                 delegate:self cancelButtonTitle:[Util localizedStringForKey:@"StringNo"] otherButtonTitles:[Util localizedStringForKey:@"StringYes"],nil]autorelease];
	[deleteAllIssuesAlert show];
    
    deleteAllIssuesAlert.tag = DELETEALLISSUEALERTTAG;

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == PURCHASEALERTTAG) {
        if (buttonIndex == 1) {
            _downloadInProgress = YES;
            Issue *issue = [array objectAtIndex:selectedIndex];
            [_ePubService downloadIssuePreviewWithIssue:issue];
                
                progressView = (DownloadProgressView*)[[[NSBundle mainBundle] loadNibNamed:@"DownloadProgressView" owner:nil options:nil] objectAtIndex:0];
                progressView.dowloadingText.text = [Util localizedStringForKey:@"MessageDownloadingPreview"];
                [self.view addSubview:progressView];
                [self.view bringSubviewToFront:toolbarView];
                [self setFrames];
        }
    }
    else if(alertView.tag == DELETEALLISSUEALERTTAG){
        if (buttonIndex == 1) {
            [self deleteAllIssues];
            //HomeViewController * homeVC =( HomeViewController *) [self parentViewController];
            //[homeVC openNewsstand];
        }else{
            return;
        }
    }
    
    
    
    
}

-(void)deleteAllIssues{

     LappKabelAppDelegate *appDelegate = (LappKabelAppDelegate*)[UIApplication sharedApplication].delegate;
    Issue *i;
    for (i in array) {
        [i deleteIssue];
        [appDelegate deleteBookmarks:i.contentFilename];
        [appDelegate deleteNotes:i.contentFilename];
        [appDelegate deleteArticlesInfo:i.contentFilename];
        [appDelegate deleteWeblinks:i.contentFilename];
    }
    [Util writAllIssuesDataToPlist:array];
    
   
    if (appDelegate.isOffline) {
        NSMutableArray *arr = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for(Issue *i in array){
            if (i.previewed && !(i.deleted)) {
                [arr addObject:i];
            }
            HomeViewController  *homeVC = (HomeViewController*)self.parentViewController;
            [homeVC updateIssuesArray:arr ];  
        }
    }
    [self reloadIssues];
    [issuesGridView reloadData];
    
}

-(void)dowloadProgressWithEPubService:(EPubService *)ePubService andProgress:(float)progress{
    //NSLog(@"@Progress is %f",progress);
    
    if (progressView != nil) {
        [progressView updateProgressBar:progress];
    }
}
-(void)dowloadfailedWithEPubService:(EPubService*)ePubService{
    [progressView removeFromSuperview];
    self.view.userInteractionEnabled = YES;
    _downloadInProgress = NO;
}
-(void)unZippingStartedWithEPubService:(EPubService*)ePubService{
    [progressView startActivityIndicator];
}
-(void)dowloadCompletedWithEPubService:(EPubService*)ePubService{
    [progressView removeFromSuperview];
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:[Util localizedStringForKey:@"TitleDonwnloadComplete"] message:[Util localizedStringForKey:@"MessagePreviewDownloaded"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [Util writAllIssuesDataToPlist:array];
    
    self.view.userInteractionEnabled = YES;
    _downloadInProgress = NO;
    [self reloadIssues];
    [issuesGridView reloadData];
}

-(void)productPurchased:(IAPHelper*)helper andAuthentcationKey:(NSString *)key{

    Issue *issue = [array objectAtIndex:selectedIndex];
    issue.authenticationKey = key;
    
    [_ePubService downloadCompleteIssueWithIssue:issue];
            
    progressView = (DownloadProgressView*)[[[NSBundle mainBundle] loadNibNamed:@"DownloadProgressView" owner:nil options:nil] objectAtIndex:0];
    progressView.dowloadingText.text = [Util localizedStringForKey:@"MessageDownloadingIssue"];
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:toolbarView];
    [self setFrames];
   
}
- (void)setFrames{
       if (progressView!=nil) {
         CGRect r = progressView.frame;
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            r.origin.x  = -180;
            r.origin.y = -83;
            r.size.width = 1384;
            r.size.height = 1024;
            progressView.frame = r;
        }else{
            r.origin.x = -130;
            r.origin.y = -50 ;
            r.size.width = 1030;
            r.size.height = 2048;
            progressView.frame = r;
        }
           [progressView updateframes];
    }
  }


-(void)initilizeConfigDictionary{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"Library" ofType:@"plist"];
    
    if ([manager fileExistsAtPath:configFilePath]) {
        _configDict  = [[NSDictionary alloc] initWithContentsOfFile:configFilePath];
    }else{
        //still to hanlde if file does not exists
    }
}
-(void)cancelTransanction{
    self.view.userInteractionEnabled = YES;
}


@end
