//
//  UITableView+Extension.m
//  HFTableViewEmpty
//
//  Created by CoderHF on 2018/4/4.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import "UITableView+Extension.h"
#import <objc/runtime.h>


@interface CategoryNoteView : UIView
@property (nonatomic) UIButton *refreshBtn;
- (instancetype)newNoteViewInView:(UIView *)view;

- (void)addNoteViewWithImageName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg;

@end
#pragma mark - NoteView
@interface CategoryNoteView()

@property (nonatomic)UIImageView *bgImgView;
@property (nonatomic)UILabel *noteLabel;
@end

@implementation CategoryNoteView

- (instancetype)newNoteViewInView:(UIView *)view {
    CGRect frame = view.bounds;
    CategoryNoteView *note = [self initWithFrame:frame];
    note.backgroundColor = view.backgroundColor;
    return note;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.bgImgView];
    [self addSubview:self.noteLabel];
}


- (void)addNoteViewWithImageName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg {
    
    self.bgImgView.image = [UIImage imageNamed:picName];
    self.noteLabel.text = noteText;
    
    if (btnImg) {
        [self addSubview:self.refreshBtn];
        [self.refreshBtn setBackgroundImage:[UIImage imageNamed:btnImg] forState:UIControlStateNormal];
        self.refreshBtn.frame = CGRectMake(0, 0, self.refreshBtn.currentBackgroundImage.size.width, self.refreshBtn.currentBackgroundImage.size.height);
    }
    
    //    [self layoutCustomViews];
}


- (void)layoutSubviews {
    
    self.bgImgView.frame = CGRectMake(self.frame.size.width/2 - self.bgImgView.image.size.width/2, (self.frame.size.height - 64)/2.0 - 20 - self.bgImgView.image.size.height/2, self.bgImgView.image.size.width, self.bgImgView.image.size.height);
    
    self.noteLabel.frame = CGRectMake(0, CGRectGetMaxY(self.bgImgView.frame) + 20, self.frame.size.width, 20);
    [self.noteLabel sizeToFit];
    
    if (self.refreshBtn) {
        if (self.noteLabel.text.length > 0) {
            self.refreshBtn.center = CGPointMake(self.frame.size.width/2.0, CGRectGetMaxY(self.noteLabel.frame) + 25 + self.refreshBtn.currentBackgroundImage.size.height / 2.0);
        }else {
            //无提示文字时、将btn上移
            self.refreshBtn.center = CGPointMake(self.frame.size.width/2.0, CGRectGetMaxY(self.bgImgView.frame) + 25 + self.refreshBtn.currentBackgroundImage.size.height / 2.0);
        }
    }
}

#pragma  mark  lazz
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [UIImageView new];
    }
    return _bgImgView;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.textAlignment = NSTextAlignmentCenter;
        _noteLabel.font = [UIFont systemFontOfSize:13.0];
        _noteLabel.numberOfLines = 0;
    }
    return _noteLabel;
}

- (UIButton *)refreshBtn {
    if (!_refreshBtn) {
        _refreshBtn = [[UIButton alloc] init];
    }
    return _refreshBtn;
}

@end
typedef void (^CallBack)(void);

@interface UITableView ()

@property (nonatomic) CallBack callBack;


@end
static char HFNoteView = 'HFNoteView';
static char HFCallBack = 'HFCallBack';

@implementation UITableView (Extension)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[UITableView new] swizzleMethod:@selector(reloadData) withMethod:@selector(HFreloadData)];
    });
}
- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class class = [self class];
    //获取类的实例方法
    Method originalMethod = class_getInstanceMethod(class, origSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
//    class_addMethod:如果发现方法已经存在，会失败返回，也可以用来做检查用,我们这里是为了避免源方法没有实现的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
//    1.如果返回成功:则说明被替换方法没有存在.也就是被替换的方法没有被实现,我们需要先把这个方法实现,然后再执行我们想要的效果,用我们自定义的方法去替换被替换的方法. 这里使用到的是class_replaceMethod这个方法. class_replaceMethod本身会尝试调用class_addMethod和method_setImplementation，所以直接调用class_replaceMethod就可以了)
//
//    2.如果返回失败:则说明被替换方法已经存在.直接将两个方法的实现交换即
    

    BOOL didAddMethod = class_addMethod(class,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
- (void)setNoteView:(UIView *)noteView{
    return objc_setAssociatedObject(self, &HFNoteView, noteView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)noteView{
    return objc_getAssociatedObject(self, &HFNoteView);
}
-(void)setCallBack:(CallBack)callBack{
    return objc_setAssociatedObject(self, &HFCallBack, callBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(CallBack)callBack {
    return objc_getAssociatedObject(self, &HFCallBack);

}
- (void)addNoteViewWithImageName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg callBack:(void (^)(void))callBack{
    
    CategoryNoteView *noteView = [[CategoryNoteView alloc] newNoteViewInView:self];
    [noteView addNoteViewWithImageName:picName noteText:noteText refreshBtnImg:btnImg];
    if (btnImg) {
        [noteView.refreshBtn addTarget:self action:@selector(noteViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
        if (callBack) {
            self.callBack = callBack;
        }
    }
    //self.noteView可能有两种。另一种为使用者自定义传入
    self.noteView = noteView;
}
- (void)noteViewBtnClick {
    [self.noteView removeFromSuperview];
    if (self.callBack) {
        self.callBack();
    }
    [self reloadData];
}




- (void)HFreloadData {
    [self HFreloadData];
    //这里。如果没有使用类别操作tableView。则不进行新代码注入。
    if (self.noteView) {
        [self checkDataSource];
    }
}

- (void)checkDataSource {
    id <UITableViewDataSource> dataSource = self.dataSource;
    NSInteger numberOfSections = [dataSource numberOfSectionsInTableView:self];
    for (int i = 0; i < numberOfSections; i++) {
        if ( [dataSource tableView:self numberOfRowsInSection:i] != 0) {
            [self.noteView removeFromSuperview];
            return;
        }
    }
    [self.superview addSubview:self.noteView];
}





@end
