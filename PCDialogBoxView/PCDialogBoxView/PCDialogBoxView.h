//
//  PCDialogBoxView.h
//  PCDialogBoxView
//
//  Created by lyricdon on 16/1/13.
//  Copyright © 2016年 lyricdon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PCDialogBoxViewStyleNickname = 1000000,
    PCDialogBoxViewStylePhone,
    PCDialogBoxViewStyleAdress,
    PCDialogBoxViewStyleEmail,
}PCDialogBoxViewStyle;

@interface PCDialogBoxView : UIView
{

}

/* 省市是否自动选中 */
@property (nonatomic, assign) BOOL autoSelected;

/* 弹出修改界面 */
- (void)showDetailInfoHudWithButton:(UIButton *)sender animated:(BOOL)animated;

- (instancetype)initWithDetailView:(UIView *) view;

@end
