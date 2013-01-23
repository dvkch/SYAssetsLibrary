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
    ALAssetRepresentation *rep = [self defaultRepresentation];
    NSString *name = [rep filename];
    return name;
}

-(void)clearCachedImagesRepresentationsAndMetadata
{
    self->_cachedDefaultRepresentation = nil;
    self->_cachedFullResolutionImage = nil;
    self->_cachedFullScreenImage = nil;
    self->_cachedThumbnail = nil;
    self->_cachedMetadata = nil;
}

-(NSDictionary*)metadata
{
    if(self->_cachedMetadata)
        return self->_cachedMetadata;
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    self->_cachedMetadata = [rep metadata];
    return self->_cachedMetadata;
}

-(UIImage*)thumbnail
{
    if(self->_cachedThumbnail)
        return self->_cachedThumbnail;
    
    ALAsset *asset = [self itemReference];
    self->_cachedThumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
    return self->_cachedThumbnail;
}

-(UIImage*)fullScreenImage
{
    if(self->_cachedFullScreenImage)
        return self->_cachedFullScreenImage;
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    self->_cachedFullScreenImage = [UIImage imageWithCGImage:[rep fullScreenImage]];
    return self->_cachedFullScreenImage;
}

-(UIImage*)fullResolutionImage
{
    if(self->_cachedFullResolutionImage)
        return self->_cachedFullResolutionImage;
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    self->_cachedFullResolutionImage = [UIImage imageWithCGImage:[rep fullResolutionImage]];
    return self->_cachedFullResolutionImage;
}

-(ALAssetRepresentation*)defaultRepresentation
{
    if(self->_cachedDefaultRepresentation)
        return self->_cachedDefaultRepresentation;
    
    ALAsset *asset = [self itemReference];
    self->_cachedDefaultRepresentation = [asset defaultRepresentation];
    return self->_cachedDefaultRepresentation;
}

@end
