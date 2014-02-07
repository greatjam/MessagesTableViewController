//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSBubbleMessageCell.h"

#import "JSAvatarImageFactory.h"
#import "UIColor+JSMessagesView.h"

static const CGFloat kJSLabelPadding = 5.0f;
static const CGFloat kJSTimeStampLabelHeight = 15.0f;
static const CGFloat kJSSubtitleLabelHeight = 15.0f;
static const CGFloat kJSBubbleOffsetX   = 4.f;


@interface JSBubbleMessageCell()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

- (void)configureTimestampLabel;
- (void)configureAvatarImageView:(UIImageView *)imageView forMessageType:(JSBubbleMessageType)type;
- (void)configureSubtitleLabelForMessageType:(JSBubbleMessageType)type;

- (void)configureWithType:(JSBubbleMessageType)type
          bubbleImageView:(UIImageView *)bubbleImageView
                  message:(id<JSMessageData>)message
        displaysTimestamp:(BOOL)displaysTimestamp
                   avatar:(BOOL)hasAvatar;

- (void)setText:(NSString *)text;
- (void)setTimestamp:(NSDate *)date;
- (void)setSubtitle:(NSString *)subtitle;

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress;

- (void)handleMenuWillHideNotification:(NSNotification *)notification;
- (void)handleMenuWillShowNotification:(NSNotification *)notification;

@end



@implementation JSBubbleMessageCell

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(handleLongPressGesture:)];
        [_longPressGesture setMinimumPressDuration:0.4f];
        [self addGestureRecognizer:_longPressGesture];
    }
    [_timestampLabel removeFromSuperview];
    _timestampLabel = nil;
    
    [_subtitleLabel removeFromSuperview];
    _subtitleLabel = nil;
}

- (void)configureWithType:(JSBubbleMessageType)type
          bubbleImageView:(UIImageView *)bubbleImageView
                  message:(id<JSMessageData>)message
        displaysTimestamp:(BOOL)displaysTimestamp
                   avatar:(BOOL)hasAvatar
{
    [self setup];
    
    [self configureTimestampLabel];
    _timestampLabel.hidden = !displaysTimestamp;
    
    [self configureSubtitleLabelForMessageType:type];
    _subtitleLabel.hidden = ![message sender];
    
    [self configureAvatarImageView:[[UIImageView alloc] init] forMessageType:type];
    _avatarImageView.hidden = !hasAvatar;
    
    [self configureBubbleViewForMessageType:type bubbleImageView:bubbleImageView message:message avatar:hasAvatar];
}

- (void)configureTimestampLabel
{
    if (!_timestampLabel) {
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kJSLabelPadding,
                                                                 kJSLabelPadding,
                                                                 self.contentView.frame.size.width - (kJSLabelPadding * 2.0f),
                                                                 kJSTimeStampLabelHeight)];
      label.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
      label.backgroundColor = [UIColor clearColor];
      label.textAlignment = NSTextAlignmentCenter;
      label.textColor = [UIColor js_messagesTimestampColorClassic];
      label.shadowColor = [UIColor whiteColor];
      label.shadowOffset = CGSizeMake(0.0f, 1.0f);
      label.font = [UIFont boldSystemFontOfSize:12.0f];
      
      [self.contentView addSubview:label];
      [self.contentView bringSubviewToFront:label];
      _timestampLabel = label;
    }
}

- (void)configureSubtitleLabelForMessageType:(JSBubbleMessageType)type
{
    if (!_subtitleLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kJSLabelPadding,
                                                                   self.contentView.frame.size.height - kJSSubtitleLabelHeight,
                                                                   self.contentView.frame.size.width - (kJSLabelPadding * 2.0f),
                                                                   kJSTimeStampLabelHeight)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = (type == JSBubbleMessageTypeOutgoing) ? NSTextAlignmentRight : NSTextAlignmentLeft;
        label.textColor = [UIColor js_messagesTimestampColorClassic];
        label.font = [UIFont systemFontOfSize:12.5f];
        
        [self.contentView addSubview:label];
        _subtitleLabel = label;
    }
}


- (void)configureAvatarImageView:(UIImageView *)imageView forMessageType:(JSBubbleMessageType)type
{
    CGFloat avatarX = 0.5f;
    if (type == JSBubbleMessageTypeOutgoing) {
        avatarX = (self.contentView.frame.size.width - kJSAvatarImageSize);
    }
    
    CGFloat avatarY = self.contentView.frame.size.height - kJSAvatarImageSize;
    if (_subtitleLabel) {
        avatarY -= kJSSubtitleLabelHeight;
    }
    
    imageView.frame = CGRectMake(avatarX, avatarY, kJSAvatarImageSize, kJSAvatarImageSize);
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                         | UIViewAutoresizingFlexibleLeftMargin
                                         | UIViewAutoresizingFlexibleRightMargin);
    
    [self.contentView addSubview:imageView];
    [_avatarImageView removeFromSuperview];
    _avatarImageView = imageView;
    _avatarImageView.frame = CGRectMake(avatarX, avatarY, kJSAvatarImageSize, kJSAvatarImageSize);;
}

- (void)configureBubbleViewForMessageType:(JSBubbleMessageType)type
                          bubbleImageView:(UIImageView *)bubbleImageView
                                  message:(id<JSMessageData>)message
                                   avatar:(BOOL)hasAvatar
{
    CGFloat bubbleX = 0.0f;
    CGFloat offsetX = 0.0f;
    
    if (hasAvatar) {
        offsetX = kJSBubbleOffsetX;
        bubbleX = kJSAvatarImageSize;
        if (type == JSBubbleMessageTypeOutgoing) {
            offsetX = kJSAvatarImageSize - kJSBubbleOffsetX;
        }
    }
    
    CGFloat bubbleViewHeight = [JSBubbleView neededHeightForText:[message text]];
    CGFloat offsetY = self.contentView.frame.size.height - bubbleViewHeight - kJSLabelPadding;
    if (!self.subtitleLabel.hidden) offsetY -= self.subtitleLabel.frame.size.height;
    
    CGRect frame = CGRectMake(bubbleX - offsetX,
                              offsetY,
                              self.contentView.frame.size.width - bubbleX,
                              bubbleViewHeight);
    
    JSBubbleView *bubbleView = [[JSBubbleView alloc] initWithFrame:frame
                                                        bubbleType:type
                                                   bubbleImageView:bubbleImageView];
    
    bubbleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                   | UIViewAutoresizingFlexibleHeight
                                   | UIViewAutoresizingFlexibleBottomMargin);
    
    [self.contentView addSubview:bubbleView];
    [self.contentView sendSubviewToBack:bubbleView];
    [_bubbleView removeFromSuperview];
    _bubbleView = bubbleView;
}

#pragma mark - Initialization

- (instancetype)initWithBubbleType:(JSBubbleMessageType)type
                   bubbleImageView:(UIImageView *)bubbleImageView
                           message:(id<JSMessageData>)message
                 displaysTimestamp:(BOOL)displaysTimestamp
                         hasAvatar:(BOOL)hasAvatar
                   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self init];
    if (self) {
        [self configureWithType:type
                bubbleImageView:bubbleImageView
                        message:message
              displaysTimestamp:displaysTimestamp
                         avatar:hasAvatar];
    }
    return self;
}

- (void)dealloc
{
    _bubbleView = nil;
    _timestampLabel = nil;
    _avatarImageView = nil;
    _subtitleLabel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - CollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.bubbleView.textView.text = nil;
    self.timestampLabel.text = nil;
    self.avatarImageView = nil;
    self.subtitleLabel.text = nil;
}

- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
    [self.contentView setBackgroundColor:color];
    [self.bubbleView setBackgroundColor:color];
}

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    self.bubbleView.textView.text = text;
}

- (void)setTimestamp:(NSDate *)date
{
    self.timestampLabel.text = [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterShortStyle];
}

- (void)setSubtitle:(NSString *)subtitle
{
	self.subtitleLabel.text = subtitle;
}

- (void)setMessage:(id<JSMessageData>)message
{
    [self setText:[message text]];
    [self setTimestamp:[message date]];
    [self setSubtitle:[message sender]];
}

- (void)setAvatarImageView:(UIImageView *)imageView
{
    [_avatarImageView removeFromSuperview];
    _avatarImageView = nil;
    
    [self configureAvatarImageView:imageView forMessageType:[self messageType]];
}

#pragma mark - Getters

- (JSBubbleMessageType)messageType
{
    return _bubbleView.type;
}

#pragma mark - Class methods

+ (CGFloat)neededHeightForBubbleMessageCellWithMessage:(id<JSMessageData>)message
                                             timeStamp:(BOOL)displayTimpStamp
                                                avatar:(BOOL)hasAvatar
{
    CGFloat timestampHeight = [message date] && displayTimpStamp ? kJSTimeStampLabelHeight : 0.0f;
	CGFloat subtitleHeight = [message sender] ? kJSSubtitleLabelHeight : 0.0f;
    
    CGFloat subviewHeights = timestampHeight + subtitleHeight + kJSLabelPadding;
    
    CGFloat avatarHeight = hasAvatar ? kJSAvatarImageSize : 0.0f;
    CGFloat bubbleHeight = [JSBubbleView neededHeightForText:[message text]];
    return subviewHeights + MAX(avatarHeight, bubbleHeight + kJSLabelPadding);
}

#pragma mark - Copying

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.bubbleView.textView.text];
    [self resignFirstResponder];
}

#pragma mark - Gestures

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    CGRect targetRect = [self convertRect:[self.bubbleView bubbleFrame]
                                 fromView:self.bubbleView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    self.bubbleView.bubbleImageView.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    self.bubbleView.bubbleImageView.highlighted = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

@end