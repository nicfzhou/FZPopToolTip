//
//  ViewController.m
//  FZPopToolTip
//
//  Created by 周峰 on 15/7/2.
//  Copyright (c) 2015年 MIT. All rights reserved.
//

#import "ViewController.h"
#import "FZPopToolTip.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    
}

-(void) viewDidAppear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)action:(id)sender {
    FZPopToolTip* tip = [FZPopToolTip new];
    [tip addAction:^(){ NSLog(@"1");} forTitle:@"hello"];
    [tip addAction:^(){ NSLog(@"2");} forTitle:@"hello2"];
    [tip addAction:^(){ NSLog(@"3");} forTitle:@"hello2"];
    [tip addAction:^(){ NSLog(@"4");} forTitle:@"dfadf sadfa dasdlfaj ;a "];
    [tip addAction:^(){ NSLog(@"5");} forTitle:@"hello2"];
    [tip addAction:^(){ NSLog(@"6");} forTitle:@"hello2"];
    [tip showOnView:self.button];
}

@end
