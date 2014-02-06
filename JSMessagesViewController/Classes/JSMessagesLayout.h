//
//  JSMessagesLayout.h
//  JSMessagesDemo
//
//  Created by Zou Alex on 14-2-6.
//  Copyright (c) 2014年 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSMessagesLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat springDamping;
@property (nonatomic, assign) CGFloat springFrequency;
@property (nonatomic, assign) CGFloat resistanceFactor;

@end
