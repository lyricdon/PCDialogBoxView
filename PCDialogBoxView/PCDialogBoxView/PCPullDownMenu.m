//
//  PCPullDownMenu.m
//  PCDialogBoxView
//
//  Created by lyricdon on 16/1/13.
//  Copyright © 2016年 lyricdon. All rights reserved.
//

#import "PCPullDownMenu.h"

@implementation PCPullDownMenu

+ (instancetype)pullDownMenuWithView:(UIView *)aView delegate:(id)aDelegate
{
    
    PCPullDownMenu *pullDownMenu = [[PCPullDownMenu alloc] init];
    pullDownMenu.frame = CGRectMake(aView.frame.origin.x, CGRectGetMaxY(aView.frame), aView.frame.size.width, pullDownMenu.rowHeight * 6);
    pullDownMenu.delegate = aDelegate;
    pullDownMenu.dataSource = aDelegate;
    pullDownMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
    pullDownMenu.layer.cornerRadius = 5;
    pullDownMenu.layer.masksToBounds = YES;
    pullDownMenu.tag = aView.tag;
    
    if (aView.tag == 0) {
        [pullDownMenu registerClass:[UITableViewCell class] forCellReuseIdentifier:@"provinceCell"];
    }else{
        [pullDownMenu registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    }
    
    return pullDownMenu;
}

@end
