//
//  UITableView+Extension.h
//  HFTableViewEmpty
//
//  Created by CoderHF on 2018/4/4.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Extension)
//支持自定义noteView
@property (nonatomic) UIView * noteView;


//refreshBtnImg为nil则不展示Btn callBack 就是刷新 button 要执行的方法
- (void)addNoteViewWithImageName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg callBack:(void (^)(void))callBack;
@end
