//
//  SYAssetItem.m
//  SYAssetsLibraryExample
//
//  Created by rominet on 12/13/12.
//  Copyright (c) 2012 Syan. All rights reserved.
//

#import "SYAssetItem.h"

@implementation SYAssetItem

-(SYAssetItem*)initWithURL:(NSURL*)url andAssetLibrary:(ALAssetsLibrary*)assetLibrary
{
    if(self = [super init])
    {
        self->_url = url;
        self->_assetLibrary = assetLibrary;
        self->_asset = nil;
    }
    return self;
}

-(SYAssetItem*)initWithAsset:(ALAsset*)asset andAssetLibrary:(ALAssetsLibrary*)assetLibrary
{
    if(self = [super init])
    {
        self->_url = [[asset defaultRepresentation] url];
        self->_assetLibrary = assetLibrary;
        self->_asset = asset;
    }
    return self;
}

-(NSURL*)itemURL
{
    return self->_url;
}

-(ALAsset *)itemReference
{
    if(self->_asset)
        return self->_asset;
    
    __block ALAsset *assetAtUrl = nil;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self->_assetLibrary assetForURL:self->_url resultBlock:^(ALAsset *asset) {
        if(asset)
            assetAtUrl = asset;
        dispatch_semaphore_signal(sema);
    } failureBlock:^(NSError *error) {
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    // caching for furthuer use
    self->_asset = assetAtUrl;
    return assetAtUrl;
}

-(BOOL)isEqual:(id)object
{
    if(!object || ![object isKindOfClass:[SYAssetItem class]])
        return NO;
    
    return [[self itemURL] isEqual:[(SYAssetItem*)object itemURL]];
}

-(NSString*)filename
{
    ALAsset *asset = [self itemReference];
    NSString *name = [[asset defaultRepresentation] filename];
    return name;
}

@end
