//
//  SYAssetAlbum.h
//  SYAssetsLibraryExample
//
//  Created by rominet on 12/13/12.
//  Copyright (c) 2012 Syan. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>

@interface SYAssetAlbum : NSObject {
    NSURL *_url;
    ALAssetsLibrary *_assetLibrary;
    ALAssetsGroup *_group;
}

-(SYAssetAlbum*)initWithURL:(NSURL*)url andAssetLibrary:(ALAssetsLibrary*)assetLibrary;

-(NSURL*)albumURL;
-(ALAssetsGroup*)albumReference;

-(NSString*)name;

-(NSInteger)itemsCount;
-(NSArray*)itemsInAlbum;

@end
