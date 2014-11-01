//
//  StoryCommentCell.m
//  ParallaxTableViewHeader
//
//  Created by Vinodh  on 26/10/14.
//  Copyright (c) 2014 Daston~Rhadnojnainva. All rights reserved.
//

#import "StoryCommentCell.h"


@interface StoryCommentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *commentAuthorIcon;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLikesCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (nonatomic) NSDictionary *comment;
@end

static CGFloat kPaddingDist = 8.0f;
static CGFloat kDefaultCommentCellHeight = 40.0f;
static CGFloat kTableViewWidth = -1;
static CGFloat kStandardButtonSize = 50.0f;
static CGFloat kStandardLabelHeight = 20.0f;

#define kCommentCellFont  [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14]

@implementation StoryCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    NSString *comment = self.comment[kCommentKey];
    CGFloat cellHeight = [StoryCommentCell heightForComment:comment];
    CGRect frame = self.commentLabel.frame;
    frame.size.height = cellHeight;
    self.commentLabel.frame = frame;
    
    frame = self.commentDateLabel.frame;
    frame.origin.x = self.commentAuthorIcon.frame.origin.x + self.commentAuthorIcon.frame.size.width + kPaddingDist;
    frame.origin.y = self.commentLabel.frame.origin.y + self.commentLabel.frame.size.height + kPaddingDist;
    self.commentDateLabel.frame = frame;
    
    frame = self.commentsLikesCountLabel.frame;
    frame.origin.x = self.likeButton.frame.origin.x - kPaddingDist - self.commentsLikesCountLabel.frame.size.width;
    frame.origin.y = self.commentDateLabel.frame.origin.y;
    self.commentsLikesCountLabel.frame = frame;
    
    frame = self.likeButton.frame;
    frame.origin.y = self.contentView.frame.origin.y + self.contentView.frame.size.height - frame.size.height - kPaddingDist;
    self.likeButton.frame = frame;
    [super layoutSubviews];
}

#pragma mark -
#pragma mark Interface

+ (void)setTableViewWidth:(CGFloat)tableWidth
{
    kTableViewWidth = tableWidth;
}

+ (id)storyCommentCellForTableWidth:(CGFloat)width
{
    StoryCommentCell *cell = [[StoryCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = width;
    cell.frame = cellFrame;
    
    //Left AuthorIconView
    UIImageView *authOrIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingDist, kPaddingDist, kStandardButtonSize, kStandardButtonSize)];
    authOrIconView.image = [UIImage imageNamed:@"authIcon"];
    authOrIconView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:authOrIconView];
    cell.commentAuthorIcon = authOrIconView;

    //Like Button
    UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width - (kPaddingDist + kStandardButtonSize), kPaddingDist, kStandardButtonSize, 38)];
    [likeButton setImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateNormal];
    [cell addSubview:likeButton];
    cell.likeButton = likeButton;
    
    
    //Comment Label
    CGRect labelRect = CGRectMake(authOrIconView.frame.origin.x + authOrIconView.frame.size.width + kPaddingDist,
                                  authOrIconView.frame.origin.y,
                                  likeButton.frame.origin.x - (kPaddingDist * 3 + authOrIconView.frame.size.width),
                                  kStandardLabelHeight);
    UILabel *commentlabe = [[UILabel alloc] initWithFrame:labelRect];
    commentlabe.font = kCommentCellFont;
    commentlabe.textColor = [UIColor darkGrayColor];
    commentlabe.textAlignment = NSTextAlignmentLeft;
    commentlabe.numberOfLines = 0;
    commentlabe.lineBreakMode = NSLineBreakByWordWrapping;
    commentlabe.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.commentLabel = commentlabe;
    [cell addSubview:commentlabe];
    
    //commentDateLabel;
    UILabel *commentDatelabe = [[UILabel alloc] initWithFrame:CGRectMake(commentlabe.frame.origin.x, commentlabe.frame.origin.y + commentlabe.frame.size.height + kPaddingDist, commentlabe.frame.size.width, commentlabe.frame.size.height)];
    commentDatelabe.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:10];
    commentDatelabe.textColor = [UIColor grayColor];
    commentDatelabe.textAlignment = NSTextAlignmentLeft;
    cell.commentDateLabel = commentDatelabe;
    [cell addSubview:commentDatelabe];
    
    return cell;
}

+ (CGFloat)cellHeightForComment:(NSString *)comment
{
    return kDefaultCommentCellHeight + [StoryCommentCell heightForComment:comment];
}

+ (CGFloat)heightForComment:(NSString *)comment
{
    CGFloat height = 0.0;
    CGFloat commentlabelWidth = kTableViewWidth - 2 * (kStandardButtonSize + kPaddingDist);
    CGRect rect = [comment boundingRectWithSize:(CGSize){commentlabelWidth, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:kCommentCellFont}
                                        context:nil];
    height = rect.size.height;
    return height;
}

- (void)configureCommentCellForComment:(NSDictionary *)comment
{
    self.comment = comment;
    self.commentLabel.text = comment[kCommentKey];
    self.commentDateLabel.text = comment[kTimeKey];
    self.commentsLikesCountLabel.text = comment[kLikesCountKey];
    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Private


@end
