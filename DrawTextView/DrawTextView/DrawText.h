//
//  DrawText.h
//  DrawTextView
//
//  Created by wanglidan on 16/6/15.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef NS_OPTIONS (NSUInteger, BLOrientation) {
    BL_ORIENTATION_HORIZONTAL         = 1 << 0,   //水平方向
    BL_ORIENTATION_VERTICAL           = 1 << 1,   //垂直方向
};

typedef NS_ENUM(NSUInteger, BLTextAlignment) {
    BL_TEXT_ALIGNMENT_CENTER   = 0,    // Visually center aligned
    BL_TEXT_ALIGNMENT_TOP      = 1,    // Visually top aligne1d
    BL_TEXT_ALIGNMENT_LEFT     = 2,    // Visually left aligned
    BL_TEXT_ALIGNMENT_BOTTOM   = 3,    // Visually bottom aligned
    BL_TEXT_ALIGNMENT_RIGHT    = 4,    // Visually right aligned
};

@interface DrawText : NSObject

/** 画布大小 */
@property (nonatomic, assign) CGSize context_size;

/** 布局方向信息 */
@property (nonatomic, assign) BLOrientation orientation;

/** 文字的字体大小 */
@property (nonatomic, assign) CGFloat font_size;

/** 文字的颜色 */
@property (nonatomic, strong) UIColor *text_color;

/** 文字的行间距 */
@property (nonatomic, assign) CGFloat line_space;

/** 文字的字符间距 */
@property (nonatomic, assign) CGFloat kern_space;

/** 文字的最大行数 */
@property (nonatomic, assign) NSInteger line_number;

/** 文字的对齐方式 */
@property (nonatomic, assign) BLTextAlignment text_alignment;

/** 文字的排版方式 */
@property (nonatomic, assign) CTFrameProgression text_frame_progression;

/** 需要绘制的文字 */
@property (nonatomic, strong) NSString *textString;


- (UIImage *)generateImageFromContext;



@end
