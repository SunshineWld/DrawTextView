//
//  ViewController.m
//  DrawTextView
//
//  Created by wanglidan on 16/6/15.
//  Copyright © 2016年 wanglidan. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
#import "DrawText.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DrawText *drawText = [[DrawText alloc] init];
//    这是最好的时代，这是最坏的时代，这是智⬇️慧的时代，这是愚蠢的时代；这是信仰的时期，这是怀疑的时期；这是光明的季节，这是黑暗的季节；这是希望之春，这是失望之冬；人们面前有着各样事物，人们面abcdefg前一无所有；人们正在23455直登天堂；人们正☺️在直下地狱。物，人们面前一无所有；人们正在直登天堂；人们正在直下地狱物，人们面前一无所有；人们正在直登天堂；人们正在直下地狱物，人们面前一无所有；人们正在直登天堂；人们正在直下地狱
    drawText.textString = @"这是最好的时代，这是最坏的时代，这是智⬇️慧的时代，这是愚蠢的时代；这是信仰的时期，这是怀疑的时期；这是光明的季节，这是黑暗的季节；这是希望之春，这是失望之冬；人们面前有着各样事物，人们面前一无所有；人们正直登天堂；人们正在直下地狱。物，人们面前一无所有；人们正在直登天堂；人们正在直下地狱物，人们面前一无所有；人们正在直登天堂；人们正在直下地狱物，人们面前一无所有；人们正在直登天堂；人们正在直下地狱";
    //设置画布尺寸
    drawText.context_size = CGSizeMake(800, 800);
    //设置行间距
    drawText.line_space = 6;
    //设置字符间距
    drawText.kern_space = 2;
    //设置字体
    drawText.font_size = 30;
    //设置文本颜色
    drawText.text_color = [UIColor whiteColor];
    //设置文字方向
    drawText.orientation = BL_ORIENTATION_VERTICAL;
    //设置文字排列方式
    drawText.text_frame_progression = kCTFrameProgressionLeftToRight;
    //设置文字对齐方式
    drawText.text_alignment = BL_TEXT_ALIGNMENT_LEFT;
    //设置文本显示行数
    drawText.line_number = 2;
    
    UIImage *image = [drawText generateImageFromContext];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, 320, 400)];
    imageView.backgroundColor = [UIColor redColor];
    imageView.image = image;
    [self.view addSubview:imageView];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
