//
//  Issue.m
//  Apperplace_TemplateProject
//
//  Created by Muhammad Jabbar on 1/31/12.
//  Copyright (c) 2012 Muhammad Jabbar. All rights reserved.
//

#import "Issue.h"
#import "clsGlobal.h"
#import "clsGlobalKeys.h"
#define ISSUEPREVIEWED @"previewed"
#define ISSUEPURCHASED @"dowloaded"
#define ISSUEDOWNLOADINFO @"downloadinfo"
#define ISSUEDELETED @"deleted"

@interface  Issue(Private) 

-(void)writeDataToIssuesPlist:(NSString*)issueKey forkey:(NSString*)key;

@end


@implementation Issue
@synthesize name = _name;
@synthesize dateCreated = _dateCreated;
@synthesize productID = _productID;
@synthesize publicURL = _publicURL;
@synthesize privateURL = _privateURL;
@synthesize coverImageURL = _coverImageURL;
@synthesize thumbImageURL = _thumbImageURL;
@synthesize publicFolderSize = _publicFolderSize;
@synthesize privateFolderSize = _privateFolderSize;
@synthesize previewAvailable = _previewAvailable;
@synthesize issueTOC = _issueTOC;
@synthesize purchasePrice = _purchasePrice;
@synthesize previewed = _previewed;
@synthesize purchased = _purchased;
@synthesize deleted = _deleted;
@synthesize coverImagePath;
@synthesize authenticationKey = _authenticationKey;
@synthesize contentFilename = _contentFilename;
@synthesize displayName = _displayName;


-(void)dealloc
{
    SAFE_RELEASE(_displayName);
    SAFE_RELEASE(_name);
    SAFE_RELEASE(_dateCreated);
    SAFE_RELEASE(_productID);
    SAFE_RELEASE(_publicURL);
    SAFE_RELEASE(_privateURL);    
    SAFE_RELEASE(_coverImageURL);
    SAFE_RELEASE(_thumbImageURL);
   // SAFE_RELEASE(_issueTOC);   
    SAFE_RELEASE(_purchasePrice);
    [super dealloc];
}
-(id)initWithDataDictionary:(NSDictionary*)dictionary
{
    if ((self = [super init])) {
        _displayName = [dictionary objectForKey:@"issueName"];
        _name = [dictionary objectForKey:@"issueDisplayTitleMAIN"];
        _dateCreated  = [dictionary objectForKey:@"issueDate"];
        _productID = [dictionary objectForKey:@"issueProductID"];
        
        NSString *string = [dictionary objectForKey:@"issuePublicBaseURL"];
        _publicURL = string;
       
        string = [dictionary objectForKey:@"issuePrivateBaseURL"];
        _privateURL = string;
        _coverImageURL =[NSURL URLWithString:[dictionary objectForKey:@"issueCoverImageFileName"]];
        _thumbImageURL = [NSURL URLWithString:[dictionary objectForKey:@"issueCoverthumbImageFileName"]];
        _previewAvailable = [[dictionary objectForKey:@"previewAvailable"]boolValue];
        _publicFolderSize = [dictionary objectForKey:@"publicFoldersize"];
        _privateFolderSize = [dictionary objectForKey:@"privateFoldersize"];
        _contentFilename = [dictionary objectForKey:kIndexPlistIssueContentFileName];
        _issueTOC = [[NSArray alloc] initWithArray:[dictionary objectForKey:kIndexPlistIssueTableOfContents]];
        
        NSDictionary *downlaodInfoDict = [dictionary objectForKey:ISSUEDOWNLOADINFO];
        
        //as conversion will return NO if value is nil so need to check nil value
        _previewed = [[downlaodInfoDict objectForKey:ISSUEPREVIEWED] boolValue];
        _purchased = [[downlaodInfoDict objectForKey:ISSUEPURCHASED] boolValue];
       _deleted = [[downlaodInfoDict objectForKey:ISSUEDELETED] boolValue];
        
    }
    return  self;
    
}

-(id) initWithCoder: (NSCoder*) coder {
    if (self = [super init]) {
        _displayName = [[coder decodeObjectForKey:@"DisplayName"]retain];
        _name = [[coder decodeObjectForKey:@"Name"]retain];
        _dateCreated = [[coder decodeObjectForKey:@"DateCreated"]retain];
        _productID = [[coder decodeObjectForKey:@"ProductID"]retain];
        _publicURL = [[coder decodeObjectForKey:@"PublicURL"]retain];
        _privateURL = [[coder decodeObjectForKey:@"PrivateURL"]retain];
        _previewAvailable = [coder decodeBoolForKey:@"PreviewAvailable"];
        _publicFolderSize = [[coder decodeObjectForKey:@"PublicFolderSize"]retain];
        _privateFolderSize = [[coder decodeObjectForKey:@"PrivateFolderSize"]retain];
        _contentFilename = [[coder decodeObjectForKey:@"ContentFilename"]retain];
        _issueTOC = [coder decodeObjectForKey:@"IssueTOC"];
        _previewed = [coder decodeBoolForKey:@"Previewed"];
        _purchased =  [coder decodeBoolForKey:@"Purchased"];
        _deleted = [coder decodeBoolForKey:@"deleted"];
        
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder*) coder {
    [coder encodeObject:_displayName forKey:@"DisplayName"];
    [coder encodeObject:_name forKey:@"Name"];
    [coder encodeObject: _dateCreated forKey:@"DateCreated"];
    [coder encodeObject:_productID forKey:@"ProductID"]; 
    [coder encodeObject:_publicURL forKey:@"PublicURL"]; 
    [coder encodeObject:_privateURL forKey:@"PrivateURL"]; 
    [coder encodeBool:_previewAvailable forKey:@"PreviewAvailable"];
    [coder encodeObject:_publicFolderSize forKey:@"PublicFolderSize"];
    [coder encodeObject:_privateFolderSize forKey:@"PrivateFolderSize"];
    [coder encodeObject:_contentFilename forKey:@"ContentFilename"];
    //[coder encodeObject:_issueTOC forKey:@"IssueTOC"];
    [coder encodeBool:_previewed forKey:@"Previewed"];
    [coder encodeBool:_purchased forKey:@"Purchased"];
    [coder encodeBool:_deleted forKey:@"deleted"];
    
}


- (NSString *)getCoverImagePath{
    
    return [[NSString stringWithFormat:@"~/Documents/covers/%@.png",[self.name stringByReplacingOccurrencesOfString:@"/" withString:@""]] stringByExpandingTildeInPath];
}

-(void)deleteIssue{
   _deleted = YES;
    [self writeDataToIssuesPlist:_name forkey:ISSUEDELETED];
}
-(void)purchaseIssue{
    _purchased = YES;
    _deleted = NO;
    [self writeDataToIssuesPlist:_name forkey:ISSUEPURCHASED];
    [self writeDataToIssuesPlist:_name forkey:ISSUEDELETED];
}
-(void)previewIssue{
    _deleted = NO;
    _previewed = YES;
    [self writeDataToIssuesPlist:_name forkey:ISSUEPREVIEWED];
    [self writeDataToIssuesPlist:_name forkey:ISSUEDELETED];
}
-(void)writeDataToIssuesPlist:(NSString*)issueKey forkey:(NSString*)key
{
	//Get the complete users document directory path.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	//Get the first path in the array.
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//Create the complete path to the file.
	NSString *issuesInfofilePath = [documentsDirectory stringByAppendingPathComponent:@"DownloadedIssuesInformation.plist"];
	
	//Check if the file exists or not.
    NSDictionary *fileData = [NSMutableDictionary dictionaryWithContentsOfFile:issuesInfofilePath];
    
    NSMutableDictionary *issueDict = [fileData objectForKey:issueKey];
    
    BOOL value = NO;
    if ([key isEqualToString:ISSUEDELETED]) {
        value = _deleted;
    }
    
    if ([key isEqualToString:ISSUEPREVIEWED]) {
        value = _previewed;
    }
    
    if ([key isEqualToString:ISSUEPURCHASED]) {
        value = _purchased;
    }

    if (issueDict != nil) {
        [issueDict setValue:[NSNumber numberWithBool:value] forKey:key];
    }else{
        issueDict = [[[NSMutableDictionary alloc]init] autorelease];
        [issueDict setValue:[NSNumber numberWithBool:value] forKey:key];
    }
    [fileData setValue:issueDict forKey:issueKey];
    [fileData writeToFile:issuesInfofilePath atomically:YES];
	
}

@end
