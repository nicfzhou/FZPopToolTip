# FZPopToolTip

为任意UIView类型控件添加pop tool tip（类似UItextField中长按显示的浮动功能条），使用方式非常简单

    FZPopToolTip* tip = [FZPopToolTip new];
    [tip addAction:^(){ NSLog(@"1");} forTitle:@"hello"];//action为你在点击某个title之后应该执行的功能
    [tip addAction:^(){ NSLog(@"2");} forTitle:@"hello2"];
    [tip addAction:^(){ NSLog(@"3");} forTitle:@"hello2"];
    [tip addAction:^(){ NSLog(@"4");} forTitle:@"dfadf sadfa dasdlfaj ;a "];
    [tip addAction:^(){ NSLog(@"5");} forTitle:@"hello2"];
    [tip addAction:^(){ NSLog(@"6");} forTitle:@"hello2"];
    [tip showOnView:self.button];
    
    
tip在点击之后会自动消失，如果tip没有retain则会自动释放，如果被retain了，想再次使用，只要再调用一次showOnView即可（注意两次showonView的targetView必须要一致）



快捷显示方式：

    -(void) showOnView:(UIView *)view withTouchCondition:(FZViewTouchCondition) condition;

调用后，指定view发送指定condition事件时才会弹出tip，事件包括长按、点按、双击事件；针对常用环境，使用更加便捷


