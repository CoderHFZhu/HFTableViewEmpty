//
//  ViewController.m
//  HFTableViewEmpty
//
//  Created by CoderHF on 2018/4/4.
//  Copyright © 2018年 CoderHF. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+Extension.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSInteger numberOfSections;

@property (nonatomic) UIView * noteView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addNoteView];
//    [self addCustomNoteView];
    [self.tableView reloadData];

}
- (void)addNoteView {
    [self.tableView addNoteViewWithImageName:@"reload" noteText:@"可以添加下拉刷新，和没有引用这个类一样的用法，也可以点击按钮刷新" refreshBtnImg:@"detail_btn_filladdress" callBack:^{
        self.numberOfSections ++;
        [self.tableView reloadData];
    }];
}
- (void)addCustomNoteView {
    UILabel *customNoteView = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    customNoteView.numberOfLines = 0;
    customNoteView.text = @"我们是自定义视图，你可以传递一个视图 或者button 都是可以的  然后回调方法自己实现就行了";
    
    self.tableView.noteView = customNoteView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 0;
    }
    return ((section%2)==0)?1:2;
}
- (IBAction)addSource:(id)sender {
    self.numberOfSections ++;
    [self.tableView reloadData];
}
- (IBAction)subSource:(id)sender {
    self.numberOfSections --;
    if (self.numberOfSections < 0 ) {
        self.numberOfSections = 0;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.numberOfSections;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = ((indexPath.row%2)==0)?[UIColor orangeColor]:[UIColor greenColor];;
    return cell;
}

@end
