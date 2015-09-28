//
//  TableViewController.m
//  FMDBSample
//
//  Created by 刘瑞刚 on 15/9/28.
//  Copyright © 2015年 刘瑞刚. All rights reserved.
//

#import "TableViewController.h"
#import <FMDB/FMDB.h>
#import <BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <Masonry.h>
#import <ReactiveCocoa.h>

@interface TableViewController ()

@property (nonatomic,strong) UITextField *nameText;
@property (nonatomic,strong) UITextField *ageText;
@property (nonatomic,strong) UIButton *addBtn;
@property (nonatomic,strong) UIButton *clearBtn;
@property (nonatomic, retain) NSString * dbPath;
@property (nonatomic,retain) NSMutableArray *data;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FMDB Sample";
    self.dbPath = @"/tmp/tmp.db";
    self.data = [NSMutableArray array];
    
    [self configureHeaderView];
    [self createDBTable];
    [self queryData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return a generic cell if all else fails
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//禁止cell被点击

    NSInteger row = indexPath.row;
    NSDictionary *dic = self.data[row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"id:%ld  name:%@  age:%@",(long)row,[dic objectForKey:@"name"],[dic objectForKey:@"age"]];
    return cell;
}

#pragma mark -
#pragma mark - config view

-(void)configureHeaderView {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 130)];
    
    self.nameText = [[UITextField alloc]init];
    self.nameText.placeholder = @"Input Name";
    self.nameText.bk_shouldBeginEditingBlock = ^(UITextField *textField){
        textField.text = @"";
        return YES;
    };
    
    self.ageText = [[UITextField alloc]init];
    self.ageText.placeholder = @"Input Age";
    self.ageText.bk_shouldBeginEditingBlock = ^(UITextField *textField){
        textField.text = @"";
        return YES;
    };
    
    self.addBtn = [[UIButton alloc]init];
    self.addBtn.backgroundColor = [UIColor redColor];
    [self.addBtn setTitle:@"Add" forState:UIControlStateNormal];
    [self.addBtn bk_addEventHandler:^(id sender) {
        [self insertDataToDB];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.clearBtn = [[UIButton alloc]init];
    self.clearBtn.backgroundColor = [UIColor redColor];
    [self.clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    [self.clearBtn bk_addEventHandler:^(id sender) {
        [self clearAllData];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:self.nameText];
    [view addSubview:self.ageText];
    [view addSubview:self.addBtn];
    [view addSubview:self.clearBtn];
    
    @weakify(self)
    [self.nameText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(300, 20));
        make.centerX.mas_equalTo(view.mas_centerX);
    }];
    
    [self.ageText mas_makeConstraints:^(MASConstraintMaker *make) {
       @strongify(self)
        make.top.equalTo(self.nameText.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(300, 20));
        make.centerX.mas_equalTo(view.mas_centerX);
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.top.equalTo(self.ageText.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(300, 20));
        make.centerX.mas_equalTo(view.mas_centerX);
    }];
    
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.top.equalTo(self.addBtn.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(300, 20));
        make.centerX.mas_equalTo(view.mas_centerX);
    }];
    
    self.tableView.tableHeaderView = view;
}

#pragma mark -
#pragma mark - FMDB Opertate

-(void)createDBTable {
    if (self.dbPath.length) {
        FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
        if ([db open]) {
            NSString *sql = @"CREATE TABLE 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'name' VARCHAR(30), 'age' VARCHAR(30))";
            BOOL res = [db executeUpdate:sql];
            
            if (!res) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"error when creating db table");
            }
            
            [db close];
        } else {
            NSLog(@"error when open db");
        }
    }
}

-(void)insertDataToDB {
    static int idx = 0;
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    
    if ([db open]) {
        NSString *sql = @"insert into user (name,age) values(?,?)";
        NSString *name = [NSString stringWithFormat:@"zhangSan%d", idx++];
        NSNumber *age = [NSNumber numberWithInt:idx];
        
        if (self.nameText.text.length) {
            name = self.nameText.text;
        }
        
        if (self.ageText.text.length) {
            age = [NSNumber numberWithInt:[self.ageText.text intValue]];
        }
        
        BOOL res = [db executeUpdate:sql, name, age];
        if (!res) {
            NSLog(@"error insert data to db");
        } else {
            NSLog(@"success insert data to db");
        }
        
        [db close];
        [self queryData];
    }
}

-(void)clearAllData {
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString * sql = @"delete from user";
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error to delete db data");
        } else {
            NSLog(@"success to delete db data");
        }
        [db close];
        [self queryData];
    }
}

-(void)queryData {
    [self.data removeAllObjects];
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    
    if ([db open]) {
        NSString *sql = @"select * from user";
        FMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]) {
            int userId = [rs intForColumn:@"id"];
            NSString * name = [rs stringForColumn:@"name"];
            NSString * age = [rs stringForColumn:@"age"];
            
            NSLog(@"user id = %d, name = %@, age = %@", userId, name, age);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:userId],@"id",name,@"name",age,@"age", nil];
            [self.data addObject:dic];
        }
        [db close];
    }
    
    [self.tableView reloadData];
}

@end
