//
//  Issue.h
//  Apperplace_TemplateProject
//
//  Created by Muhammad Jabbar on 1/31/12.
//  Copyright (c) 2012 Muhammad Jabbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Issue : NSObject<NSCoding>
{
    NSString *_displayName;
    NSString *_name;
    NSString *_dateCreated;
    NSString *_productID;
    
    
    NSString *_publicURL;
    NSString *_privateURL;
    
    NSURL *_coverImageURL;
    NSURL *_thumbImageURL;
 
   
    NSString *_publicFolderSize;
    NSString *_privateFolderSize;
    NSString *_purchasePrice;
    
    
    
    BOOL _previewAvailable;
    BOOL _previewed;
    BOOL _purchased;
    BOOL _deleted;
    
    NSArray *_issueTOC;
    
    NSString *_authenticationKey;
    
    NSString *_contentFilename;
    
    
}
@property (nonatomic ,readonly) NSString *name;
@property (nonatomic ,readonly) NSString *displayName;
@property (nonatomic ,readonly) NSString *dateCreated;
@property (nonatomic ,readonly) NSString *productID;

@property (nonatomic , readonly) NSString *publicURL;
@property (nonatomic , readonly) NSString *privateURL;
@property (nonatomic , readonly) NSURL *coverImageURL;
@property (nonatomic , readonly) NSURL *thumbImageURL;

@property (nonatomic ,readonly) NSString *publicFolderSize;
@property (nonatomic ,readonly) NSString *privateFolderSize;
@property (nonatomic ,retain) NSString *purchasePrice;

@property (nonatomic ,readonly) BOOL previewAvailable;

@property (nonatomic ,readonly) NSArray *issueTOC;
@property (nonatomic , readonly, getter = getCoverImagePath) NSString *coverImagePath;
@property (nonatomic ,assign) BOOL previewed;
@property (nonatomic ,assign) BOOL purchased;
@property (nonatomic ,assign) BOOL deleted;
@property (nonatomic ,retain) NSString *authenticationKey;
@property (nonatomic,readonly) NSString *contentFilename;  
-(id)initWithDataDictionary:(NSDictionary*)dictionary;
-(void)deleteIssue;
-(void)purchaseIssue;
-(void)previewIssue;


@end
