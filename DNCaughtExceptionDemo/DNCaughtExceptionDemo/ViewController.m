//
//  ViewController.m
//  DNCaughtExceptionDemo
//
//  Created by ucsmy on 2017/7/20.
//  Copyright © 2017年 ucsmy. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray * _array;
    NSString * _Selected;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _array = [[NSArray alloc] initWithObjects:@"California",
                   @"Tuna 00001",
                   nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click:(id)sender {
    
    NSArray *arr = [NSArray arrayWithObjects:@"1",@"2", nil];
    NSLog(@"%@",[arr objectAtIndex:3]);
}
- (IBAction)click2:(UIButton *)sender {

}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    NSString * sushiName = [_array objectAtIndex:indexPath.row];
    NSString *sushiString = [[NSString alloc] initWithFormat:@"%ld: %@", (long)indexPath.row, sushiName];
    cell.textLabel.text = sushiString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * sushiName = [_array objectAtIndex:indexPath.row];
    NSString * sushiString = [NSString stringWithFormat:@"%ld: %@", (long)indexPath.row, sushiName];
    
    NSString * message = [NSString stringWithFormat:@"a:%@.  b: %@", _Selected, sushiString];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sushi Power!"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
    
    _Selected = sushiString;
}

- (void)viewDidUnload {
    [_array release];
    _array = nil;
}

- (void)dealloc {
    [_tableView release];
    [_array release];
    _array = nil;
    [_Selected release];
    _Selected = nil;
    [super dealloc];
}
@end
