//
//  SYAssetAlbum.m
//  SYAssetsLibraryExample
//
//  Created by rominet on 12/13/12.
//  Copyright (c) 2012 Syan. All rights reserved.
//

#import "SYAssetAlbum.h"
#import "SYAssetItem.h"

@implementation SYAssetAlbum

-(SYAssetAlbum*)initWithURL:(NSURL*)url andAssetLibrary:(ALAssetsLibrary*)assetLibrary
{
    if(self = [super init])
    {
        self->_url = url;
        self->_assetLibrary = assetLibrary;
        self->_group = nil;
    }
    return self;
}

-(NSURL*)albumURL
{
    return self->_url;
}

-(ALAssetsGroup*)albumReference
{
    if(self->_group)
        return self->_group;
    
    __block ALAssetsGroup *assetsGroupAtUrl = nil;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self->_assetLibrary groupForURL:self->_url resultBlock:^(ALAssetsGroup *group) {
        if(group)
            assetsGroupAtUrl = group;
        dispatch_semaphore_signal(sema);
    } failureBlock:^(NSError *error) {
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    // caching for furthuer use
    self->_group = assetsGroupAtUrl;
    return assetsGroupAtUrl;
}

-(NSString*)name
{
    ALAssetsGroup *group = [self albumReference];
    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
    return name;
}

-(NSInteger)itemsCount
{
    ALAssetsGroup *group = [self albumReference];
    return [group numberOfAssets];
}

-(NSArray*)itemsInAlbum
{
    ALAssetsGroup *group = [self albumReference];
    __block NSMutableArray *items = [NSMutableArray array];
    __block NSUInteger count = 0;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        ALAsset *originalAsset = [result originalAsset] ? [result originalAsset] : result;
        SYAssetItem *item = [[SYAssetItem alloc] initWithAsset:originalAsset andAssetLibrary:self->_assetLibrary];
        [items addObject:item];
        
        ++count;
        if(count == [group numberOfAssets])
            dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return [NSArray arrayWithArray:items];
}

@end
