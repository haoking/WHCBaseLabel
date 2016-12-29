//
//  WHCLabel.m
//  WHCAPP
//
//  Created by Haochen Wang on 12/2/16.
//  Copyright © 2016 WHC. All rights reserved.
//

#import "WHCLabel.h"

@interface WHCLabel ()

@property (nonatomic, strong) NSMutableArray *attributedTextArray;
@property (nonatomic, strong) NSMutableAttributedString *attString;

@property (nonatomic, copy) tapLabelHandler handler;

@end

@implementation WHCLabel

NSString * const NSStringFromTextStyle(TextStyle textStyle)
{
    switch (textStyle)
    {
        case TextStyleFont:
            return NSFontAttributeName;
        case TextStyleColor:
            return NSForegroundColorAttributeName;
        case TextStyleBackgroundColor:
            return NSBackgroundColorAttributeName;
        case TextStyleTextArtLigature:
            return NSLigatureAttributeName;
        case TextStyleSeparate:
            return NSKernAttributeName;
        case TextStyleDeleteLine:
            return NSStrikethroughStyleAttributeName;
        case TextStyleDeleteLineColor:
            return NSStrikethroughColorAttributeName;
        case TextStyleUnderline:
            return NSUnderlineStyleAttributeName;
        case TextStyleUnderlineColor:
            return NSUnderlineColorAttributeName;
        case TextStyleOutlineWidth:
            return NSStrokeWidthAttributeName;
        case TextStyleOutlineColor:
            return NSStrokeColorAttributeName;
        case TextStyleShadow:
            return NSShadowAttributeName;
        case TextStyleTextArtPress:
            return NSTextEffectAttributeName;
        case TextStyleOffsetX:
            return NSBaselineOffsetAttributeName;
        case TextStyleOffsetY:
            return NSObliquenessAttributeName;
        case TextStyleDraw:
            return NSExpansionAttributeName;
        case TextStyleDirection:
            return NSWritingDirectionAttributeName;
        case TextStyleDirectionXY:
            return NSVerticalGlyphFormAttributeName;
        case TextStylelink:
            return NSLinkAttributeName;
        case TextStyleAttachment:
            return NSAttachmentAttributeName;
        case TextStyleParagraph:
            return NSParagraphStyleAttributeName;
        default:
            return nil;
    }
}

NSInteger const NSIntegerFromLineStyle(LineStyle lineStyle)
{
    switch (lineStyle)
    {
        case LineStyleNone:
            return NSUnderlineStyleNone;
        case LineStyleFine:
            return NSUnderlineStyleSingle;
        case LineStyleThick:
            return NSUnderlineStyleThick;
        case LineStyleDouble:
            return NSUnderlineStyleDouble;
        default:
            return 0;
    }
}

NSInteger const NSIntegerFromDirection(Direction direction)
{
    switch (direction)
    {
        case DirectionEmbeddingL2R:
            return NSWritingDirectionLeftToRight|NSWritingDirectionEmbedding;
        case DirectionOverrideL2R:
            return NSWritingDirectionLeftToRight|NSWritingDirectionOverride;
        case DirectionEmbeddingR2L:
            return NSWritingDirectionRightToLeft|NSWritingDirectionEmbedding;
        case DirectionOverrideR2L:
            return NSWritingDirectionRightToLeft|NSWritingDirectionOverride;
        default:
            return 0;
    }
}

#pragma mark -- label package --

/**
 * 封装label模块.
 *
 */

+(instancetype)labelCreateText:(NSString *)text textCor:(UIColor *)color textSize:(UIFont *)size
{
    return [[self alloc] initWithText:text textCor:color textSize:size];
}

-(id)initWithText:(NSString *)text textCor:(UIColor *)color textSize:(UIFont *)size
{
    self = [super initWithFrame:CGRectZero];
    if (!self)
    {
        return nil;
    }
    [self setBackgroundColor:[UIColor clearColor]];
    self.textAlignment = NSTextAlignmentCenter;
    [self setText:(text==nil?@"":text)];
    [self setTextColor:(color==nil?[UIColor blackColor]:color)];
    [self setFont:(size==nil?[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]:size)];
    self.multipleTouchEnabled = NO;
    self.clipsToBounds = YES;

    NSDictionary *headerAttributeDict = @{NSForegroundColorAttributeName: (color==nil?[UIColor blackColor]:color),
                                          NSFontAttributeName: (size==nil?[UIFont systemFontOfSize:[UIFont labelFontSize]]:size)};
    NSMutableAttributedString *attributedHeaderText = [[NSMutableAttributedString alloc] initWithString:(text==nil?@"":text) attributes:headerAttributeDict];
    self.attString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedHeaderText];
    return self;
}

-(void)addBlock:(tapLabelHandler)block
{
    self.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self addGestureRecognizer:labelTapGestureRecognizer];
    self.handler = block;
}

-(void)labelTouchUpInside:(UITapGestureRecognizer *)recognizer
{
    if (_handler)
    {
        _handler(self);
    }
}

-(NSMutableArray *)attributedTextArray
{
    if (!_attributedTextArray)
    {
        _attributedTextArray = [NSMutableArray array];
    }
    return _attributedTextArray;
}

-(void)addAttributedText:(NSString *)text withTextStyle:(TextStyle)textStyle withObj:(id)obj
{
    if ([text isEqualToString:@""] || text == nil)
    {
        return;
    }

    @try
    {
        NSString *style = NSStringFromTextStyle(textStyle);
        NSDictionary *headerAttributeDict = @{style: obj};

        NSMutableAttributedString *attributedHeaderText = [[NSMutableAttributedString alloc] initWithString:text attributes:headerAttributeDict];
        [self.attributedTextArray addObject:attributedHeaderText];
        for (NSMutableAttributedString *attString in self.attributedTextArray)
        {
            [self.attString appendAttributedString:attString];
        }
        [self setAttributedText:self.attString];
    }
    @catch (NSException *exception)
    {
        NSLog(@"AttributedText is somthing wrong.");
    }
    @finally
    {
    }
}

-(void)addAttributedText:(NSString *)text withTextStyleDic:(NSDictionary *)dic
{
    if ([text isEqualToString:@""] || text == nil)
    {
        return;
    }

    @try
    {
        NSMutableDictionary *headerAttributeDict = [NSMutableDictionary dictionary];

        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

            id value;
            if ([key integerValue] == TextStyleDeleteLine || [key integerValue] == TextStyleUnderline)
            {
                value = @(NSIntegerFromLineStyle([obj integerValue]));
            }
            else if ([key integerValue] == TextStyleDirection)
            {
                value = @(NSIntegerFromDirection([obj integerValue]));
            }
            else
            {
                value = obj;
            }
            NSString *style = NSStringFromTextStyle([key integerValue]);
            [headerAttributeDict setObject:value forKey:style];
        }];
        NSMutableAttributedString *attributedHeaderText = [[NSMutableAttributedString alloc] initWithString:text attributes:headerAttributeDict];
        [self.attributedTextArray addObject:attributedHeaderText];
        for (NSMutableAttributedString *attString in self.attributedTextArray)
        {
            [self.attString appendAttributedString:attString];
        }
        [self setAttributedText:self.attString];
    }
    @catch (NSException *exception)
    {
        NSLog(@"AttributedText is somthing wrong.");
    }
    @finally
    {
    }
}


@end
