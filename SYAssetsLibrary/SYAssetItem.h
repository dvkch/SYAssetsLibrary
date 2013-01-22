//
//  SYAssetItem.h
//  SYAssetsLibraryExample
//
//  Created by rominet on 12/13/12.
//  Copyright (c) 2012 Syan. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>

@interface SYAssetItem : NSObject {
    NSURL *_url;
    ALAssetsLibrary *_assetLibrary;
    ALAsset *_asset;
    
    UIImage *_cachedThumbnail;
    UIImage *_cachedFullScreenImage;
    UIImage *_cachedFullResolutionImage;
    NSDictionary *_cachedMetadata;
    ALAssetRepresentation *_cachedDefaultRepresentation;
}

-(SYAssetItem*)initWithURL:(NSURL*)url andAssetLibrary:(ALAssetsLibrary*)assetLibrary;
-(SYAssetItem*)initWithAsset:(ALAsset*)asset andAssetLibrary:(ALAssetsLibrary*)assetLibrary;

-(NSURL*)itemURL;
-(ALAsset*)itemReference;

-(NSString*)filename;

-(void)clearCachedImagesRepresentationsAndMetadata;

-(NSDictionary*)metadata;
-(UIImage*)thumbnail;
-(UIImage*)fullScreenImage;
-(UIImage*)fullResolutionImage;
-(ALAssetRepresentation*)defaultRepresentation;

@end
