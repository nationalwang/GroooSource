//
//  GRSettingViewController.m
//  GroooSource
//
//  Created by Assuner on 2017/5/6.
//  Copyright © 2017年 Assuner. All rights reserved.
//

#import "GRSettingViewController.h"
#import "GRCacheManager.h"
#import "GRAppInfoViewController.h"
#import "GRAutherInfoController.h"

@interface GRSettingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;
@property (weak, nonatomic) IBOutlet UIView *clearCacheView;
@property (weak, nonatomic) IBOutlet UIView *appInfoView;
@property (weak, nonatomic) IBOutlet UIView *autherInfoView;


@end

@implementation GRSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logoutBtn.layer.cornerRadius = 4.0f;
    self.logoutBtn.clipsToBounds = YES;
    [self.logoutBtn addTarget:self action:@selector(btnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self configBtn];
    
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"共%.3fM", [GRCacheManager cacheMemorySize]];
    [self addGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"设置";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)addObservedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configBtn) name:GRLoginSuccessNotification object:nil];
}

- (void)addGesture {
    [self.clearCacheView gr_addTapAction:^{
        if ([self.cacheSizeLabel.text isEqualToString:@"共0.000M"]) {
            [self showMessage:@"无需清理!"];
        } else {
            [self showProgress];
            [GRCacheManager clearAllCache];
            self.cacheSizeLabel.text = [NSString stringWithFormat:@"共%.3fM", [GRCacheManager cacheMemorySize]];
            [self hideProgress];
            [MBProgressHUD gr_showSuccess:@"已清理!"];
        }

    }];
    
    [self.appInfoView gr_addTapAction:^{
        [self.navigationController pushViewController:[[GRAppInfoViewController alloc] init] animated:YES];
    }];
    
    [self.autherInfoView gr_addTapAction:^{
        [self.navigationController pushViewController:[[GRAutherInfoController alloc] init] animated:YES];
    }];
}

- (void)configBtn {
    if ([GRUserManager sharedManager].currentUser.loginData.token) {
        [self.logoutBtn setBackgroundImage:[UIImage imageWithColor:[GRAppStyle groooRedColor]] forState:UIControlStateNormal];
        [self.logoutBtn setBackgroundImage:[UIImage imageWithColor:[[GRAppStyle groooRedColor] colorWithAlphaComponent:0.7]] forState:UIControlStateHighlighted];
        [self.logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    } else {
        [self.logoutBtn setBackgroundImage:[UIImage imageWithColor:[GRAppStyle mainColorWithAlpha:1.0]] forState:UIControlStateNormal];
        [self.logoutBtn setBackgroundImage:[UIImage imageWithColor:[GRAppStyle mainColorWithAlpha:0.7]] forState:UIControlStateHighlighted];
        [self.logoutBtn setTitle:@"登录" forState:UIControlStateNormal];
    }

}

#pragma - Actions

- (void)btnPressed {
    if ([GRUserManager sharedManager].currentUser.loginData.token) {
        [MBProgressHUD gr_showSuccess:@"已退出!"];
        [GRUserManager clearUserData];
        [[NSNotificationCenter defaultCenter] postNotificationName:GRLogoutSuccessNotification object:nil];
        [self back];
    } else {
        [GRRouter open:@"present->GRLoginViewController" params:nil completed:nil];
    }
}

@end
