//
//  PCDialogBoxView.m
//  PCDialogBoxView
//
//  Created by lyricdon on 16/1/13.
//  Copyright © 2016年 lyricdon. All rights reserved.
//

#import "PCDialogBoxView.h"

#define iPhone6PixelWidth 750.0f
#define iPhone6ScreenHeight 1334.0f
#define titleHeight 40 * ratio
#define iPhone4TitleHeight 35 * ratio
#define isIPhone4 [UIScreen mainScreen].bounds.size.height <= 480

#define isProvince 501

@interface PCDialogBoxView () <UITableViewDelegate, UITableViewDataSource>
{
    UIWindow *currentWindow;
    UIView *currentView;
    UIButton *currentButton;
    
    CGFloat ratio, paddingY, paddingX, leftMargin, normalheight;
}

@property (nonatomic, strong) UIButton *cover;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

// 第一行文本框
@property (nonatomic, strong) UITextField *firstTextInfo;
// 第二行文本框
@property (nonatomic, strong) UITextField *secTextInfo;

// 特殊的
@property (nonatomic, strong) UIButton *maleButton;
@property (nonatomic, strong) UIButton *femaleButton;

@property (nonatomic, strong) NSTimer *captchaTimer;
@property (nonatomic, strong) UIButton *captchaButton;

@property (nonatomic, strong) NSArray *areaData;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) UITableView *provinceView;
@property (nonatomic, strong) UITableView *cityView;
@property (nonatomic, strong) UIButton *provinceButton;
@property (nonatomic, strong) UIButton *cityButton;

@end

static NSInteger captchaCount = 60;

@implementation PCDialogBoxView

- (instancetype)initWithDetailView:(UIView *)view
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoSelected = NO;
        
        currentView = view;
        currentWindow = [UIApplication sharedApplication].keyWindow;
        ratio = currentWindow.bounds.size.width / (iPhone6PixelWidth * 0.5);
        paddingY = 10 * ratio;
        paddingX = 15 *ratio;
        leftMargin = 18 * ratio;
        normalheight = 35 * ratio;
        
        if (isIPhone4)
        {
            paddingY = 5 * ratio;
            paddingX = 8 *ratio;
        }
        
        CGFloat x = 70 / iPhone6PixelWidth * currentWindow.bounds.size.width;
        CGFloat y = 240 / iPhone6ScreenHeight * currentWindow.bounds.size.height;
        CGFloat width = 610 / iPhone6PixelWidth * currentWindow.bounds.size.width;
        CGFloat height = 372 / iPhone6ScreenHeight * currentWindow.bounds.size.height;
        self.frame = CGRectMake(x, y, width, height);
        self.layer.cornerRadius = 5;
        [self clipsToBounds];
        self.alpha = 0.0;
    }
    
    return self;
}

- (void)showDetailInfoHudWithButton:(UIButton *)sender animated:(BOOL)animated
{
    currentButton = sender;
    
    switch (sender.tag)
    {
        case PCDialogBoxViewStyleNickname:
        {
            [self setupNickNameHud];
        }
            break;
            
        case PCDialogBoxViewStylePhone:
        {
            [self setupPhoneHud];
        }
            break;
            
        case PCDialogBoxViewStyleAdress:
        {
            [self setupAddressHud];
        }
            break;
            
        case PCDialogBoxViewStyleEmail:
        {
            [self setupEmailHud];
        }
            break;
            
        default:
            break;
    }
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.cancelButton];
    [self addSubview:self.saveButton];
    
    // 遮罩
    [currentWindow addSubview:self.cover];
    [currentWindow addSubview:self];
    
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        self.alpha = 1.0;
        [UIView commitAnimations];
    }
    else
    {
        self.alpha = 1.0;
    }
}

#pragma mark 修改昵称性别
- (void)setupNickNameHud
{
    self.titleLabel.text = @"修改姓名及性别";
    
    UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(self.titleLabel.frame) + paddingY, self.bounds.size.width - 2 * leftMargin, normalheight)];
    nameField.borderStyle = UITextBorderStyleRoundedRect;
    nameField.text = @"用户名";
    [nameField becomeFirstResponder];
    [nameField addTarget:self action:@selector(judgeName:) forControlEvents:UIControlEventEditingChanged];
    self.firstTextInfo = nameField;
    
    
    UIButton *maleBtn = [[UIButton alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(nameField.frame) + paddingY, nameField.frame.size.width * 0.5 - paddingX, normalheight)];
    maleBtn.selected = YES;
    [maleBtn setTitle:@"男" forState:UIControlStateNormal];
    [maleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [maleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [maleBtn setBackgroundImage:[UIImage imageNamed:@"sex-bg"] forState:UIControlStateSelected];
    [maleBtn addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    self.maleButton = maleBtn;
    
    UIButton *femaleBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(maleBtn.frame) + 2 * paddingX, maleBtn.frame.origin.y, maleBtn.frame.size.width, maleBtn.frame.size.height)];
    femaleBtn.selected = NO;
    [femaleBtn setTitle:@"女" forState:UIControlStateNormal];
    [femaleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [femaleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [femaleBtn setBackgroundImage:[UIImage imageNamed:@"sex-bg"] forState:UIControlStateSelected];
    [femaleBtn addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    self.femaleButton = femaleBtn;
    
    [self addSubview:maleBtn];
    [self addSubview:femaleBtn];
    [self addSubview:nameField];
    
    self.saveButton.enabled = NO;
    [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)judgeName:(UITextField *)name
{
    if (name.text.length == 0 || name.text.length > 16)
    {
        self.saveButton.enabled = NO;
        [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    else
    {
        self.saveButton.enabled = YES;
        [self.saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)changeSex:(UIButton *)btn
{
    BOOL flag = btn.selected;
    if (btn == self.maleButton)
    {
        self.maleButton.selected = YES;
        self.femaleButton.selected = NO;
    }
    else
    {
        self.maleButton.selected = NO;
        self.femaleButton.selected = YES;
    }
    
    if (btn.selected != flag)
    {
        self.saveButton.enabled = YES;
        [self.saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
}

#pragma mark 修改电话
- (void)setupPhoneHud
{
    self.titleLabel.text = @"输入手机号码";
    
    UITextField *phoneField = [[UITextField alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(self.titleLabel.frame), self.bounds.size.width - 2 * leftMargin, normalheight)];
    phoneField.borderStyle = UITextBorderStyleRoundedRect;
    phoneField.keyboardType = UIKeyboardTypeNumberPad;
    phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [phoneField becomeFirstResponder];
    self.firstTextInfo = phoneField;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(phoneField.frame.origin.x, CGRectGetMaxY(phoneField.frame) + paddingX , 100 * ratio, phoneField.frame.size.height)];
    tipLabel.text = @"输入短信验证码";
    tipLabel.font = [UIFont systemFontOfSize:13 * ratio weight:3];
    tipLabel.textColor = [UIColor lightGrayColor];
    
    UITextField *codeField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tipLabel.frame) + paddingX, tipLabel.frame.origin.y, phoneField.frame.size.width - tipLabel.frame.size.width - paddingX, tipLabel.frame.size.height)];
    codeField.borderStyle = UITextBorderStyleRoundedRect;
    codeField.keyboardType = UIKeyboardTypeNumberPad;
    [codeField addTarget:self action:@selector(judgeCaptcha:) forControlEvents:UIControlEventEditingChanged];
    self.secTextInfo = codeField;
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(phoneField.frame.origin.x, self.bounds.size.height - 45 * ratio, phoneField.bounds.size.width * 0.5, titleHeight)];
    [sendBtn setTitle:@"发送短信" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:3.0];
    sendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [sendBtn addTarget:self action:@selector(sendCaptcha:) forControlEvents:UIControlEventTouchUpInside];
    self.captchaButton = sendBtn;
    
    UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(phoneField.frame.origin.x + phoneField.bounds.size.width * 0.5, self.bounds.size.height - 45 * ratio, phoneField.bounds.size.width * 0.5, titleHeight)];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:3.0];
    commitBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [commitBtn addTarget:self action:@selector(commitPhone) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.userInteractionEnabled = NO;
    
    [self addSubview:sendBtn];
    [self addSubview:commitBtn];
    [self addSubview:codeField];
    [self addSubview:tipLabel];
    [self addSubview:phoneField];
    
    // 移除全局的保存按钮
    [self.saveButton removeFromSuperview];
    self.saveButton = commitBtn;
}

- (void)judgeCaptcha:(UITextField *)captcha
{
    if (captcha.text.length == 6) {
        self.saveButton.userInteractionEnabled = YES;
        [self.saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        self.saveButton.userInteractionEnabled = NO;
        [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)sendCaptcha:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    BOOL success = 1;
    
#warning 请将一下代码放入发送短信的成功回调中
    if (success == YES) {
        [weakSelf.secTextInfo becomeFirstResponder];
        sender.userInteractionEnabled = NO;
        [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(updateCaptchaButton:) userInfo:sender repeats:YES];
        weakSelf.captchaTimer = timer;
        [weakSelf.captchaTimer fire];
    }
}

- (void)updateCaptchaButton:(NSTimer *)timer
{
    UIButton *btn = (UIButton *)timer.userInfo;
    NSString *str = [NSString stringWithFormat:@"发送短信(%02tu)",captchaCount];
    [btn setTitle:str forState:UIControlStateNormal];
    
    captchaCount--;
    
    if (captchaCount < 0) {
        captchaCount = 60;
        btn.userInteractionEnabled = YES;
        [btn setTitle:@"发送短信" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [timer invalidate];
    }
}

- (void)commitPhone
{
    //    __weak typeof(self) weakSelf = self;
    //    [self.userControl bindPhoneNumWithPhone:self.firstTextInfo.text securityCode:self.secTextInfo.text success:^{
    //        [weakSelf saveInfo];
    //    } failure:^(NSError *error) {
    //        [SlateHud showOneLineWideHUDAddedToView:currentView text:error.domain hideAfterDelay:2.0];
    //    }];
}

#pragma mark 修改地址
- (void)setupAddressHud
{
    self.titleLabel.text = @"选择地址";
    UIFont * curentFont = [UIFont systemFontOfSize:12 * ratio weight:2];
    CGFloat padding = 4 * ratio;
    
    UILabel *province = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, CGRectGetMaxY(self.titleLabel.frame) + padding, 60 * ratio, normalheight)];
    province.text = @"省/直辖市";
    province.font = curentFont;
    province.textColor = [UIColor lightGrayColor];
    
    UIButton *provinceBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(province.frame), province.frame.origin.y, 70 * ratio, province.frame.size.height)];
    [provinceBtn addTarget:self action:@selector(chooseProvince:) forControlEvents:UIControlEventTouchUpInside];
    provinceBtn.tag = isProvince;
    [self setupButton:provinceBtn text:@"北京"];
    self.provinceButton = provinceBtn;
    
    UIButton *cityBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - leftMargin - 110 * ratio, province.frame.origin.y, 110 * ratio, province.frame.size.height)];
    [cityBtn addTarget:self action:@selector(chooseCity:) forControlEvents:UIControlEventTouchUpInside];
    cityBtn.tag = isProvince + 1;
    [self setupButton:cityBtn text:@"朝阳区"];
    cityBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.cityButton = cityBtn;
    
    UILabel *city = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(provinceBtn.frame), province.frame.origin.y, cityBtn.frame.origin.x - CGRectGetMaxX(provinceBtn.frame), provinceBtn.frame.size.height)];
    city.text = @"市/区";
    city.textAlignment = NSTextAlignmentCenter;
    city.font = curentFont;
    city.textColor = [UIColor lightGrayColor];
    
    UILabel *street = [[UILabel alloc] initWithFrame:CGRectMake(province.frame.origin.x, CGRectGetMaxY(province.frame) + padding, 60 * ratio, 13 * ratio)];
    street.text = @"街道地址";
    street.font = curentFont;
    street.textColor = [UIColor lightGrayColor];
    
    UITextField *streetField = [[UITextField alloc] initWithFrame:CGRectMake(street.frame.origin.x, CGRectGetMaxY(street.frame) + padding, self.bounds.size.width -2 * leftMargin, normalheight)];
    //    streetField.text = self.userControl.user.userAddress;
    streetField.font = curentFont;
    streetField.borderStyle = UITextBorderStyleRoundedRect;
    streetField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.secTextInfo = streetField;
    
    [self addSubview:cityBtn];
    [self addSubview:city];
    [self addSubview:province];
    [self addSubview:provinceBtn];
    [self addSubview:street];
    [self addSubview:streetField];
}

- (void)setupButton:(UIButton *)sender text:(NSString *)aString
{
    [sender setTitle:aString forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
    sender.layer.cornerRadius = 5;
    [sender.layer masksToBounds];
    sender.titleLabel.font = [UIFont systemFontOfSize:12 * ratio weight:1];
    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:@"arrow_down_black"];
    [sender setImage:img forState:UIControlStateNormal];
    sender.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, paddingX);
    sender.imageEdgeInsets = UIEdgeInsetsMake(0, sender.frame.size.width - paddingX, 0, 0);
}

- (void)chooseProvince:(UIButton *)sender
{
    if (_provinceView != nil) {
        _provinceView.hidden = !_provinceView.hidden;
    }else{
        _provinceView = [self createTableView:sender];
        [currentWindow addSubview:_provinceView];
    }
    
    if (self.autoSelected == YES) {
        [_provinceView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex.section inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)chooseCity:(UIButton *)sender
{
    if (_cityView != nil) {
        _cityView.hidden = !_cityView.hidden;
    }else{
        _cityView = [self createTableView:sender];
        [currentWindow addSubview:_cityView];
    }
    
    if (self.autoSelected == YES) {
        [_cityView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (UITableView *)createTableView:(UIButton *)sender
{
    UITableView *provinceView = [[UITableView alloc] init];
    provinceView.frame = CGRectMake(sender.frame.origin.x + self.frame.origin.x, CGRectGetMaxY(sender.frame) + self.frame.origin.y, sender.frame.size.width, normalheight * 6);
    provinceView.delegate = self;
    provinceView.dataSource = self;
    provinceView.rowHeight = normalheight;
    provinceView.separatorStyle = UITableViewCellSeparatorStyleNone;
    provinceView.layer.cornerRadius = 5;
    provinceView.layer.masksToBounds = YES;
    provinceView.tag = sender.tag;
    
    if (sender.tag == isProvince) {
        [provinceView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"provinceCell"];
    }else{
        [provinceView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    }
    
    return provinceView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == isProvince) {
        return self.areaData.count;
    }
    
    return [[self.areaData[self.selectedIndex.section] valueForKey:@"city"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView.tag == isProvince) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"provinceCell"];
        cell.textLabel.text = [self.areaData[indexPath.row] valueForKey:@"province"];
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell"];
        cell.textLabel.text = [self.areaData[self.selectedIndex.section] valueForKey:@"city"][indexPath.row];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:11 * ratio];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 选中同省,不做处理
    if (tableView.tag == isProvince && self.selectedIndex.section == indexPath.row) return;
    
    tableView.hidden = YES;
    
    if (tableView.tag == isProvince) {
        self.selectedIndex = [NSIndexPath indexPathForRow:self.selectedIndex.row inSection:indexPath.row];
        
        NSDictionary *provinceDict = self.areaData[self.selectedIndex.section];
        [self.provinceButton setTitle:provinceDict[@"province"] forState:UIControlStateNormal];
        [self.cityView reloadData];
        
        // 选中不同省,自动打开市/区列表
        if (self.cityView == nil) {
            [self chooseCity:self.cityButton];
        }else{
            self.cityView.hidden = NO;
        }
        [self.cityButton setTitle:[provinceDict[@"city"] firstObject] forState:UIControlStateNormal];
        self.selectedIndex = [NSIndexPath indexPathForRow:0 inSection:self.selectedIndex.section];
    }
    else {
        self.selectedIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:self.selectedIndex.section];
        NSArray *arr = [self.areaData[self.selectedIndex.section] valueForKey:@"city"];
        [self.cityButton setTitle:arr[self.selectedIndex.row] forState:UIControlStateNormal];
    }
}

#pragma mark 修改邮箱
- (void)setupEmailHud
{
    self.titleLabel.text = @"修改邮箱账号地址";
    
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, CGRectGetMaxY(self.titleLabel.frame) + paddingY, 2 * normalheight, normalheight)];
    codeLabel.text = @"输入密码";
    codeLabel.font = [UIFont systemFontOfSize:13 * ratio weight:3];
    codeLabel.textColor = [UIColor lightGrayColor];
    
    UITextField *codeField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(codeLabel.frame) + 1, codeLabel.frame.origin.y, self.bounds.size.width - 2 * leftMargin - codeLabel.frame.size.width - 1, normalheight)];
    codeField.borderStyle = UITextBorderStyleRoundedRect;
    [codeField becomeFirstResponder];
    codeField.secureTextEntry = YES;
    self.firstTextInfo = codeField;
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(codeLabel.frame.origin.x, CGRectGetMaxY(codeLabel.frame) + paddingY , codeLabel.frame.size.width, codeLabel.frame.size.height)];
    emailLabel.text = @"输入新邮箱";
    emailLabel.font = [UIFont systemFontOfSize:13 * ratio weight:3];
    emailLabel.textColor = [UIColor lightGrayColor];
    
    UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(codeField.frame.origin.x, emailLabel.frame.origin.y, codeField.frame.size.width, codeField.frame.size.height)];
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.secTextInfo = emailField;
    
    UIButton *commitButton = [[UIButton alloc] initWithFrame:self.saveButton.frame];
    [commitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    commitButton.titleLabel.font = [UIFont systemFontOfSize:15 * ratio weight:3.0];
    commitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [commitButton setTitle:@"提交" forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(commitEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton removeFromSuperview];
    self.saveButton = commitButton;
    
    [self addSubview:commitButton];
    [self addSubview:emailField];
    [self addSubview:emailLabel];
    [self addSubview:codeLabel];
    [self addSubview:codeField];
}

- (void)commitEmail
{
    //    if (![_userControl checkPasswordFormat:self.firstTextInfo.text fromPasswordField:1]) return;
    //
    //    if (![_userControl chackEmailFormat:self.secTextInfo.text isLogin:YES]) return;
    
    // 服务器成功回调saveInfo
    //    [SlateHud showLoadingHUDAddedToView:currentView];
    //    [_userControl modifyUsernameWithEmail:self.secTextInfo.text password:self.firstTextInfo.text completion:^(BOOL success, NSError *error) {
    //        [SlateHud hideHUDForView:currentView];
    //        if (success)
    //        {
    //            [self saveInfo];
    //        }else
    //        {
    //            [SlateHud showOneLineWideHUDAddedToView:currentView text:error.domain hideAfterDelay:2.0];
    //        }
    //    }];
}


#pragma mark 公共方法
- (void)saveInfo
{
    switch (currentButton.tag)
    {
        case PCDialogBoxViewStyleNickname:
        {
            NSString *nickName = self.firstTextInfo.text;
            NSInteger sex = 1;
            
            if (self.femaleButton.selected == YES) {
                sex = 0;
            }
            
        }
            break;
            
        case PCDialogBoxViewStylePhone:
        {
            [currentButton setTitle:self.firstTextInfo.text forState:UIControlStateNormal];
        }
            break;
            
        case PCDialogBoxViewStyleAdress:
        {
            self.selectedIndex = nil;
        }
            break;
            
        case PCDialogBoxViewStyleEmail:
        {
            [currentButton setTitle:self.secTextInfo.text forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    [self closeHud];
}

- (void)closeHud
{
    // 移除时钟
    if ( self.captchaTimer != nil)
    {
        [self.captchaTimer invalidate];
        self.captchaTimer = nil;
    }
    captchaCount = 60;
    
    if (self.provinceView != nil)
    {
        self.provinceView.delegate = nil;
        [self.provinceView removeFromSuperview];
    }
    if (self.cityView != nil)
    {
        self.cityView.delegate = nil;
        [self.cityView removeFromSuperview];
    }
    
    // 移除遮罩
    [self.cover removeFromSuperview];
    [self removeFromSuperview];
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , 5 * ratio , self.bounds.size.width, titleHeight)];
        if (isIPhone4) {
            titleLabel.frame = CGRectMake(0 , 0 , self.bounds.size.width, iPhone4TitleHeight);
        }
        titleLabel.backgroundColor = [UIColor clearColor];
        
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15 * ratio weight:3.0];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil) {
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50 * ratio, 5 * ratio, titleHeight, titleHeight)];
        if (isIPhone4) {
            cancelBtn.frame = CGRectMake(self.bounds.size.width - iPhone4TitleHeight, 0, iPhone4TitleHeight, iPhone4TitleHeight);
        }
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"closed"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(closeHud) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton = cancelBtn;
    }
    return _cancelButton;
}

- (UIButton *)saveButton
{
    if (_saveButton == nil) {
        UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 45 * ratio, self.bounds.size.width, titleHeight)];
        if (isIPhone4) {
            saveBtn.frame = CGRectMake(0, self.bounds.size.height - iPhone4TitleHeight, self.bounds.size.width, iPhone4TitleHeight);
        }
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:15 * ratio weight:3.0];
        saveBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [saveBtn addTarget:self action:@selector(saveInfo) forControlEvents:UIControlEventTouchUpInside];
        _saveButton = saveBtn;
    }
    return _saveButton;
}

- (UIView *)cover
{
    if (_cover == nil) {
        // 遮罩
        UIButton *cover = [[UIButton alloc] initWithFrame:currentWindow.bounds];
        cover.backgroundColor = [UIColor lightGrayColor];
        cover.alpha = 0.4;
        _cover = cover;
    }
    return _cover;
}

//- (NSArray *)areaData
//{
//    if (_areaData == nil) {
//        NSArray *arr = [NSArray arrayWithContentsOfFile:_userControl.userAreaDictFilePath];
//        _areaData = arr.copy;
//    }
//    return _areaData;
//}
//
//- (NSIndexPath *)selectedIndex
//{
//    if (_selectedIndex == nil) {
//        short provinceNum = 0;
//        short cityNum = 0;
//        for (short i = 0; i < self.areaData.count; i++) {
//            if ([self.userControl.user.userProvince isEqualToString:self.areaData[i][@"province"]]) {
//                provinceNum = i;
//                break;
//            }
//        }
//
//        NSArray *arr = [self.areaData[provinceNum] valueForKey:@"city"];
//        for (short k = 0; k < arr.count; k++) {
//            if ([self.userControl.user.userCity isEqualToString:arr[k]]) {
//                cityNum = k;
//                break;
//            }
//        }
//        _selectedIndex = [NSIndexPath indexPathForItem:cityNum inSection:provinceNum];
//    }
//    return _selectedIndex;
//}

@end
