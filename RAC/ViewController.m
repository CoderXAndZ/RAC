//
//  ViewController.m
//  RAC
//
//  Created by admin on 2016/7/31.
//  Copyright © 2016年 XZ. All rights reserved.
//

#import "ViewController.h"
#import "XZPersonListModel.h"
#import "XZPerson.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define KDefaultOrBackgroundColor [UIColor colorWithRed:230/255.0f green:235/255.0f blue:240/255.0f alpha:1]

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableNotice;

@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) XZPerson *person;
@end

@implementation ViewController
{
    XZPersonListModel *_personListModel;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 网络事件响应
//    [self loadData];
//    // 监听按钮事件
//    [self MonitorBtnEvent];
//    // 监听输入框事件
//    [self MonitorTextField];
//    // 监听组合输入框事件
//    [self MonitorCombinationTextField];
//    // 监听多个组合输入框事件
//    [self MonitorCombinationTextField2];
    
    self.person = [[XZPerson alloc] init];
    self.person.name = @"zhangsan";
    self.person.age = 18;
    
    [self TwoWayBinding];
}

#pragma mark ----- 双向绑定
// 使用 RAC 的原因：'响应式'编程！
/**
 b = 3;
 c = 4;
 a = b + c; 7
 
 b = 100; a的值不会发生改变
 
 ‘响应式’,当修改 b或c的同时，a也发生变化！
 
 在iOS开发中，可以使用 KVO 监听对象的属性值，达到这一效果！
 因为 苹果的 KVO 会统一调用同一个方法，方法是固定的，如果监听属性过多，方法非常难以维护！
 RAC是目前实现响应式编程的唯一解决方案！
 
 * MVVM
    双向绑定！
 */
- (void)TwoWayBinding {
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 300, 40)];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:nameTextField];
    
    UITextField *ageTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 300, 40)];
    ageTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:ageTextField];
    
    __weak typeof(self)weakSelf = self;
    // 双向绑定
    // 1> 模型（KVO 数据）绑定 UI（text 属性）
    // a) name(string) -> text(string)
    RAC(nameTextField,text) = RACObserve(_person, name);
    NSLog(@"RACObserve(_person, name):%@",RACObserve(_person, name));
    // b) age(NSInteger) -> text(string)，RAC中传递的数据都是 id 类型
    // 如果使用基本数据类型绑定 UI 的内容，需要使用 map 函数，通过 block 对 value 的数值进行转换之后，才能绑定
    RAC(ageTextField,text) = [RACObserve(_person, age) map:^id _Nullable(id  _Nullable value) {
        NSLog(@"%@ %@",value,[value class]);
        
        // 错误的转换，value本身已经是 NSNumber,需要字符串
//        return [NSString stringWithFormat:@"%zd",value];
        return [value description];
    }];
    
    // 2> UI 绑定 模型
    [[RACSignal combineLatest:@[nameTextField.rac_textSignal,ageTextField.rac_textSignal]] subscribeNext:^(RACTuple * _Nullable x) {
        
        weakSelf.person.name = [x first];
        weakSelf.person.age = [[x second] integerValue];
    }];
    
    // 3> 添加按钮，输出结果
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        // 循环引用！！！
        NSLog(@"_person.name:%@  _person.age:%zd",weakSelf.person.name,weakSelf.person.age);
    }];
} 

// RAC 在使用的时候，因为系统提供的信号是始终存在的！因此,所有的block中,如果出现'self.' / '成员变量' 几乎百分之百会循环引用！
/**
 解除循环引用的方法
 1.__weak
 2.利用 RAC 提供的 weak-strong dance
    在 block 的外部使用 @weakify(self)
    在 block 的内部使用 @strongify(self)
    然后，直接使用self即可。
 */
// 成员变量不好用weak
#pragma mark ----- combineLatest:reduce:监听组合输入框事件
- (void)MonitorCombinationTextField2 {
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 300, 40)];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:nameTextField];
    
    UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 300, 40)];
    pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:pwdTextField];
    
    // reduce -> 减少的意思，合并两个信号的数据，进行汇总计算时使用的！
    // id是返回值
    // reduce 中，可以通过接收的参数进行计算，并且返回需要的数值！例：登录界面，只有用户名和密码同时存在，才允许登录！
    
    // 方法一：使用__weak避免循环引用
//    __weak typeof(self)weakSelf = self;
    // 方法二：
    @weakify(self);
    [[RACSignal combineLatest:@[nameTextField.rac_textSignal,pwdTextField.rac_textSignal] reduce:^id(NSString *name, NSString *pwd){
        NSLog(@"%@ %@",name,pwd);
        // 判断用户名和密码是否同时存在，需要转换成NSNumer类型，才能被当做 id 传递
        return @(name.length > 0 && pwd.length > 0);
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
        
        @strongify(self);
        self.btn.enabled = [x boolValue];
//        weakSelf.btn.enabled = [x boolValue];
    }];
}

#pragma mark ----- 监听组合输入框事件
- (void)MonitorCombinationTextField {
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 300, 40)];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:nameTextField];
    
    UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 300, 40)];
    pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:pwdTextField];
    
    // 组合信号 Tuple是元组,RACTuple是返回值，参数是有括号的；
    [[RACSignal combineLatest:@[nameTextField.rac_textSignal,pwdTextField.rac_textSignal]] subscribeNext:^(RACTuple * _Nullable x) {
        NSString *name = x.first;
        NSString *pwd = x.second;
        NSLog(@"name：%@ pwd：%@ [x class]:%@",name,pwd,[x class]);
        // 打印结果===name：Wertyui pwd：3456yui [x class]:RACTuple
    }];
}

#pragma mark ----- 监听输入框事件
- (void)MonitorTextField {
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 300, 40)];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:nameTextField];
    
    // 监听文本输入内容 - 参数就是输入的文本内容！
    [[nameTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@ %@",x,[x class]);
    }];
}

#pragma mark ----- 监听按钮事件
- (void)MonitorBtnEvent {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    // 监听按钮的事件 - 不再需要新建一个方法，再block里面实现相应事件
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"%@---------%@",x,[x class]);
    }];
    
    self.btn = btn;
    
    // [btn rac_signalForControlEvents:UIControlEventTouchUpInside] 是创建了一个冷信号，调用subscribeNext才订阅了信号，才会工作
}

#pragma mark ----- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _personListModel.personList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noticeCell"];
    }
    cell.textLabel.text = _personListModel.personList[indexPath.row].name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

#pragma mark --- 加载数据
- (void)loadData {
    // 1.实例化视图模型
    _personListModel = [[XZPersonListModel alloc] init];
    // 2.加载数据
    /** 
     next 是接收到数据
     error 接收到错误，错误处理
     completed 信号完成
     */
    [[_personListModel loadPersons] subscribeNext:^(id  _Nullable x) {
        NSLog(@"==============%@",x);
        // 刷新数据
        [self.tableNotice reloadData];
    } error:^(NSError * _Nullable error) {
        NSLog(@"==============%@",error);
    } completed:^{
        NSLog(@"==============完成");
    }];
}

#pragma mark --- 懒加载
- (UITableView *)tableNotice {
    if (!_tableNotice) {
        
        _tableNotice = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
        _tableNotice.delegate = self;
        _tableNotice.dataSource  = self;
        _tableNotice.backgroundColor = KDefaultOrBackgroundColor;
        _tableNotice.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableNotice.showsVerticalScrollIndicator = NO;
        [self.view addSubview:self.tableNotice];
    }
    return _tableNotice;
}
@end
