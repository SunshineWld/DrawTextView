//
//  DrawText.m
//  DrawTextView
//
//  Created by wanglidan on 16/6/15.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#define LeftTextOffset 12

#import "DrawText.h"

@interface DrawText ()

@property (nonatomic, assign) BOOL vertical; //垂直
@property (nonatomic, assign) BOOL fromLeftToRight; //从左到右
@property (nonatomic, assign) CGRect textRect;
@property (nonatomic, assign) BOOL needCutText;

@end

@implementation DrawText

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)setContext_size:(CGSize)context_size
{
    _context_size = context_size;
}
- (void)setFont_size:(CGFloat)font_size
{
    _font_size = font_size;
}
- (void)setKern_space:(CGFloat)kern_space
{
    _kern_space = kern_space;
}
- (void)setLine_space:(CGFloat)line_space
{
    _line_space = line_space;
}
- (void)setText_color:(UIColor *)text_color
{
    _text_color = text_color;
}
- (void)setLine_number:(NSInteger)line_number
{
    _line_number = line_number;
}
- (void)setOrientation:(BLOrientation)orientation
{
    _orientation = orientation;
    _vertical = _orientation == BL_ORIENTATION_HORIZONTAL ? NO : YES;
}
- (void)setText_alignment:(BLTextAlignment)text_alignment
{
    _text_alignment = text_alignment;
}
- (void)setText_frame_progression:(CTFrameProgression)text_frame_progression
{
    _text_frame_progression = text_frame_progression;
    _fromLeftToRight = _text_frame_progression == kCTFrameProgressionLeftToRight ? YES : NO;
}
- (UIImage *)generateImageFromContext
{
    //设置段落属性
    CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
    CTTextAlignment textAlignment = kCTCenterTextAlignment;
    CTParagraphStyleSetting theSettings[3] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&_line_space},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
        {kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment), &textAlignment},
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate(theSettings, 3);
    
    //设置文字属性
    NSDictionary *attribute = @{(NSString *)kCTVerticalFormsAttributeName:[NSNumber numberWithBool:_vertical],
                                (NSString *)kCTFontAttributeName:[UIFont systemFontOfSize:_font_size],
                                (NSString *)kCTKernAttributeName:[NSNumber numberWithFloat:_kern_space],
                                (NSString *)kCTForegroundColorAttributeName:_text_color,
                                (id)kCTParagraphStyleAttributeName:(id)style
                                };
    
    NSAttributedString *attString = [[NSAttributedString alloc ]
                                     initWithString:_textString
                                     attributes:attribute];
    //返回绘制区域
    _textRect = [self textRectWithNumberOfLines:_line_number withAttributeString:[attString mutableCopy]];

    if (_needCutText) {
        attString = [self lineCutAttributeStringWithTextRect:_textRect andAttributeString:[attString mutableCopy]];
    }

    //绘图
    UIGraphicsBeginImageContext(_context_size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //坐标系转换
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, _context_size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //设置文字排版方向
    NSDictionary *drawDirectionDic;
    if (_text_frame_progression && _orientation == BL_ORIENTATION_VERTICAL) {
        drawDirectionDic = @{(NSString *)kCTFrameProgressionAttributeName:[NSNumber numberWithUnsignedInt:_text_frame_progression]};
    }else{
        drawDirectionDic = nil;
    }
    //创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, _textRect);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, (CFDictionaryRef)drawDirectionDic);
    
    //绘制
    CTFrameDraw(frame, context);
    
    //生成Image
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    UIGraphicsEndImageContext();
    return image;
}
//根据绘制行数和文字，返回要绘制的区域
- (CGRect)textRectWithNumberOfLines:(NSInteger)numberOfLines withAttributeString:(NSMutableAttributedString *)attributeString
{
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, _context_size.width, _context_size.height));
    
    NSDictionary *drawDirectionDic;
    if (_text_frame_progression && _orientation == BL_ORIENTATION_VERTICAL) {
        drawDirectionDic = @{(NSString *)kCTFrameProgressionAttributeName:[NSNumber numberWithUnsignedInt:_text_frame_progression]};
    }else{
        drawDirectionDic = nil;
    }
    CTFrameRef textFrame;
    textFrame = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [attributeString length]), path, (CFDictionaryRef)drawDirectionDic);
    
    //获得显示行数
    CFArrayRef lines = CTFrameGetLines(textFrame);
    NSInteger lineNumber = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineNumber];
    CTFrameGetLineOrigins(textFrame,CFRangeMake(0,lineNumber), lineOrigins);
    
    _needCutText = NO;

    //单行文字计算其宽度
    if (lineNumber == 0 || lineNumber == 1) {

        CGFloat ascent = 0;
        CGFloat descent = 0;
        CGFloat leading = 0;
        CGFloat totalHeight = 0;
        
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, 0);
        CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        totalHeight += ascent + descent+_line_space;
        
        CGRect oneRect = [self textRectWithTextWidth:totalHeight];

        CFRelease(framesetterRef);
        CFRelease(textFrame);
        CFRelease(path);
        
        return oneRect;
    }
    
    CGPoint firstLineOrigin = lineOrigins[0];
    CGPoint secondLineOrigin = lineOrigins[1];
    CGPoint lastLineOrigin = lineOrigins[lineNumber-1];
    
    //判断numberOfLines和默认计算出来的行数的最小值，作为可以显示的行数
    if (numberOfLines < lineNumber && numberOfLines > 0) {
        NSInteger linenum = MIN(numberOfLines, lineNumber);
        //需要截断文字，重新获取最后一行的坐标
        lastLineOrigin = lineOrigins[linenum-1];
        _needCutText = YES;
    }
    
    CFRelease(framesetterRef);
    CFRelease(textFrame);
    CFRelease(path);
    
    CGRect rect = CGRectZero;
    CGFloat textWidth = 0;
    CGFloat lineWidth = 0;
    if (_vertical) {
        //垂直方向
        lineWidth = _fromLeftToRight ? secondLineOrigin.x - firstLineOrigin.x - _line_space : firstLineOrigin.x - secondLineOrigin.x - _line_space;
        textWidth = _fromLeftToRight ? lastLineOrigin.x - firstLineOrigin.x + lineWidth : firstLineOrigin.x-lastLineOrigin.x+lineWidth+5;
        
        rect = [self textRectWithTextWidth:textWidth];
        
    }else{
        //水平方向
        lineWidth = firstLineOrigin.y - secondLineOrigin.y -_line_space;
        textWidth = firstLineOrigin.y - lastLineOrigin.y + lineWidth+2;
    
        rect = [self textRectWithTextWidth:textWidth];
    }
    return rect;
}
//根据文本的宽和高返回合适的绘制区域
- (CGRect)textRectWithTextWidth:(CGFloat)textWidth
{
    CGRect rect = CGRectZero;
    if (_vertical) {
        //垂直方向
        if (_text_alignment == BL_TEXT_ALIGNMENT_LEFT) {
            rect = CGRectMake(-LeftTextOffset, 0, textWidth, _context_size.height);
        }else if (_text_alignment == BL_TEXT_ALIGNMENT_CENTER){
            rect = CGRectMake((_context_size.width-textWidth)/2, 0, textWidth, _context_size.height);
        }else if (_text_alignment == BL_TEXT_ALIGNMENT_RIGHT){
            rect = CGRectMake((_context_size.width-textWidth), 0, textWidth, _context_size.height);
        }
        
    }else{
        //水平方向
        if (_text_alignment == BL_TEXT_ALIGNMENT_CENTER) {
            rect = CGRectMake(0, (_context_size.height-textWidth)/2, _context_size.width, textWidth);
        }else if (_text_alignment == BL_TEXT_ALIGNMENT_BOTTOM){
            rect = CGRectMake(0, 0, _context_size.width, textWidth);
        }else if (_text_alignment == BL_TEXT_ALIGNMENT_TOP){
            rect = CGRectMake(0, _context_size.height-textWidth, _context_size.width, textWidth);
        }
    }
    return rect;
}
//将文字进行裁剪
- (NSAttributedString *)lineCutAttributeStringWithTextRect:(CGRect)textRect andAttributeString:(NSMutableAttributedString *)attributeString
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributeString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    NSDictionary *drawDirectionDic;
    if (_text_frame_progression && _orientation == BL_ORIENTATION_VERTICAL) {
        drawDirectionDic = @{(NSString *)kCTFrameProgressionAttributeName:[NSNumber numberWithUnsignedInt:_text_frame_progression]};
    }else{
        drawDirectionDic = nil;
    }

    CTFrameRef textFrame;
    textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributeString length]), path, (CFDictionaryRef)drawDirectionDic);
    
    //获得显示行数
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CFIndex count = CFArrayGetCount(lines);
    if (count == 0) {
        CFRelease(path);
        CFRelease(textFrame);
        CFRelease(framesetter);
        return nil;
    }
    //截到最后一行
    CTLineRef line = CFArrayGetValueAtIndex(lines, count-1);
    CFRange lastLineRange = CTLineGetStringRange(line);
    NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
    NSMutableAttributedString *cutAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
    NSMutableAttributedString *lastLineAttributeString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
    
    NSString *kEllipsesCharacter = @"...";//省略号 @"\u2026"
    //设置文字属性
    NSDictionary *attribute = @{(NSString *)kCTVerticalFormsAttributeName:[NSNumber numberWithBool:_vertical],
                                (NSString *)kCTFontAttributeName:[UIFont systemFontOfSize:_font_size],
                                (NSString *)kCTKernAttributeName:[NSNumber numberWithFloat:_kern_space*2],
                                (NSString *)kCTForegroundColorAttributeName:_text_color,
                                };
    
    NSAttributedString *ellipseAttStr = [[NSAttributedString alloc ]
                                     initWithString:kEllipsesCharacter
                                     attributes:attribute];
    
    [lastLineAttributeString appendAttributedString:ellipseAttStr];
    
    //对最后一行做处理
    lastLineAttributeString = [self cutLastLineAttributeString:lastLineAttributeString andWidth:_vertical ? CGRectGetHeight(_textRect) :  CGRectGetWidth(_textRect)];
    //替换最后一行
    cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location)] mutableCopy];
    [cutAttributedString appendAttributedString:lastLineAttributeString];
    attributeString = cutAttributedString;
    
    CFRelease(path);
    CFRelease(textFrame);
    CFRelease(framesetter);

    //最后对textRect微调
    _textRect = [self textRectWithNumberOfLines:_line_number withAttributeString:[attributeString mutableCopy]];
    return [attributeString copy];
}
- (NSMutableAttributedString *)cutLastLineAttributeString:(NSMutableAttributedString *)attributeString andWidth:(CGFloat)width
{
    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGFloat lastLineWidth = (CGFloat)CTLineGetTypographicBounds(truncationToken, nil, nil,nil);
    CFRelease(truncationToken);
    if (lastLineWidth > width) {
        [attributeString deleteCharactersInRange:NSMakeRange(attributeString.length - 5, 2)];
        //递归处理
        return [self cutLastLineAttributeString:attributeString andWidth:width];
    }else{
        return attributeString;
    }
}
@end
