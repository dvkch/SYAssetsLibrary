//
//  SYAssetLibrary.m
//  SYAssetsLibraryExample
//
//  Created by rominet on 12/13/12.
//  Copyright (c) 2012 Syan. All rights reserved.
//

#import "SYAssetLibrary.h"
#import "SYAssetAlbum.h"

@interface SYAssetLibrary (Private)
-(void)ALAssetsLibraryChangedNotification:(NSNotification*)notification;
-(void)refresh;
@end

@implementation SYAssetLibrary

@synthesize reloadBlock = _reloadBlock;

#pragma mark - Initialization

+(SYAssetLibrary *)assetLibrary
{
    return [[self alloc] initAndAskPermission];
}

-(SYAssetLibrary *)initAndAskPermission
{
    if(self = [super init])
    {
        self->_assetLibrary = [[ALAssetsLibrary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ALAssetsLibraryChangedNotification:)
                                                     name:ALAssetsLibraryChangedNotification
                                                   object:self];
        
        if(![self libraryAccessible])
        {
            [self requestPermission:^(ALAuthorizationStatus status) {
                NSString *statusString = @"";
                switch (status) {
                    case ALAuthorizationStatusAuthorized:
                        statusString = @"ALAuthorizationStatusAuthorized";
                        break;
                    case ALAuthorizationStatusDenied:
                        statusString = @"ALAuthorizationStatusDenied";
                        break;
                    case ALAuthorizationStatusNotDetermined:
                        statusString = @"ALAuthorizationStatusNotDetermined";
                        break;
                    case ALAuthorizationStatusRestricted:
                        statusString = @"ALAuthorizationStatusRestricted";
                        break;
                        
                    default:
                        statusString = @"Undefined";
                        break;
                }
                NSLog(@"Request ended with authorization: %@", statusString);
                
                [self refresh];
            }];
        }
        else
            [self refresh];
        
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALAssetsLibraryChangedNotification
                                                  object:nil];
}

#pragma mark - Private methods

-(void)ALAssetsLibraryChangedNotification:(NSNotification *)notification
{
    [self refresh];
}

-(void)refresh
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if(self.reloadBlock)
            self.reloadBlock();
    });
}

#pragma mark - Public methods

-(ALAssetsLibrary *)assertLibraryRef
{
    return self->_assetLibrary;
}

-(void)requestPermission:(void (^)(ALAuthorizationStatus))block
{
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        *stop = YES;
        if(block)
            block([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized);
    } failureBlock:^(NSError *error) {
        if(block)
            block([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized);
    }];
}

-(BOOL)libraryAccessible
{
    return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized ||
           [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted;
}

-(NSArray*)albumsWithType:(ALAssetsGroupType)albumType
{
    __block NSMutableArray *albums = [NSMutableArray array];
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self->_assetLibrary enumerateGroupsWithTypes:albumType usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group)
        {
            NSURL *url = [group valueForProperty:ALAssetsGroupPropertyURL];
            if(url)
            {
                SYAssetAlbum *album = [[SYAssetAlbum alloc] initWithURL:url andAssetLibrary:self->_assetLibrary];
                [albums addObject:album];
            }
        }
        else
        {
            dispatch_semaphore_signal(sema);
        }
    } failureBlock:^(NSError *error) {
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return [NSArray arrayWithArray:albums];
}

@end
