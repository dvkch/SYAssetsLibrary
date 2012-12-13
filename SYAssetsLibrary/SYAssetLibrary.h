//
//  SYAssetLibrary.h
//  SYAssetsLibraryExample
//
//  Created by rominet on 12/13/12.
//  Copyright (c) 2012 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class SYAlbum;


@interface SYAssetLibrary : NSObject {
@private
    ALAssetsLibrary *_assetLibrary;
}

+(SYAssetLibrary *)assetLibrary;
-(SYAssetLibrary *)initAndAskPermission;

@property (copy, nonatomic) void (^reloadBlock) (void);

-(ALAssetsLibrary *)assertLibraryRef;

-(void)requestPermission:(void(^)(ALAuthorizationStatus status))block;
-(BOOL)libraryAccessible;

-(NSArray*)albumsWithType:(ALAssetsGroupType)albumType;

@end
