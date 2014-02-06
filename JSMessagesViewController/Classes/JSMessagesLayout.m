//
//  JSMessagesLayout.m
//  JSMessagesDemo
//
//  Created by Zou Alex on 14-2-6.
//  Copyright (c) 2014年 Hexed Bits. All rights reserved.
//

#import "JSMessagesLayout.h"

@interface JSMessagesLayout()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@end

@implementation JSMessagesLayout

-(id)init {
  if ([super init]) {
    self.springDamping = 0.7;
    self.springFrequency = 0.7;
    self.resistanceFactor = 700;
  }
  return self;
}

-(void)setSpringDamping:(CGFloat)springDamping {
  if (springDamping >= 0 && _springDamping != springDamping) {
    _springDamping = springDamping;
    for (UIAttachmentBehavior *spring in _animator.behaviors) {
      spring.damping = _springDamping;
    }
  }
}

-(void)setSpringFrequency:(CGFloat)springFrequency {
  if (springFrequency >= 0 && _springFrequency != springFrequency) {
    _springFrequency = springFrequency;
    for (UIAttachmentBehavior *spring in _animator.behaviors) {
      spring.frequency = _springFrequency;
    }
  }
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  return [_animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (!_animator) {
    _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
  }
  [_animator removeAllBehaviors];
  CGSize contentSize = [self collectionViewContentSize];
  NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
  
  for (UICollectionViewLayoutAttributes *item in items) {
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    
    spring.length = 0;
    spring.damping = self.springDamping;
    spring.frequency = self.springFrequency;
    
    [_animator addBehavior:spring];
  }
  return [_animator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  UIScrollView *scrollView = self.collectionView;
  CGFloat scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
  CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
  
  for (UIAttachmentBehavior *spring in _animator.behaviors) {
    CGPoint anchorPoint = spring.anchorPoint;
    CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
    CGFloat scrollResistance = distanceFromTouch / self.resistanceFactor;
    
    UICollectionViewLayoutAttributes *item = [spring.items firstObject];
    CGPoint center = item.center;
    center.y += (scrollDelta > 0) ? MIN(scrollDelta, scrollDelta * scrollResistance)
    : MAX(scrollDelta, scrollDelta * scrollResistance);
    item.center = center;
    
    [_animator updateItemUsingCurrentState:item];
  }
  return NO;
}
@end
