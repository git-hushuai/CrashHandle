//
//  ViewController.m
//  DNCaughtExceptionDemo
//
//  Created by ucsmy on 2017/7/20.
//  Copyright © 2017年 ucsmy. All rights reserved.
//

#import "ViewController.h"
#import "UCSEncrypt.h"
#import "TestViewViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,TestVCDelegate>
{
    NSArray * _array;
    NSString * _Selected;
}

@property (nonatomic ,retain) IBOutlet UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *imgArr;
@property (nonatomic ,copy,readonly) NSString *readonlyStr;
@end
@implementation ViewController

@synthesize readonlyStr = _isreadonlyStr;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    _array = [[NSArray alloc] initWithObjects:@"California",
                   @"Tuna 00001",
                   nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.imgArr = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 数组越界Crash

 @param sender <#sender description#>
 */
- (IBAction)click:(id)sender {
    
    NSArray *arr = [NSArray arrayWithObjects:@"1",@"2", nil];
    NSLog(@"%@",[arr objectAtIndex:3]);
}

/**
  方法未找到Crash
 */
- (IBAction)click2{

}

/**
 内存溢出
 @param sender <#sender description#>
 */
- (IBAction)click4:(id)sender {
    [self click4:sender];
//   [self setValue:@"1" forKeyPath:@"readonlyStr"];
//   NSLog(@"readonly str info :%@",self.readonlyStr);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

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

/**
 野指针crash

 @param tableView <#tableView description#>
 @param indexPath <#indexPath description#>
 */
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

- (IBAction)click3:(id)sender {
    NSString *str = nil;
    NSMutableArray *arr = [NSMutableArray array];
    [arr insertObject:str atIndex:0];
}


-(UIImage *)createQRCodeImageByString:(NSString *)qrString andSize:(CGFloat)imageSize{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    CIImage * image= qrFilter.outputImage;
    // InterpolatedUIImage
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(imageSize/CGRectGetWidth(extent), imageSize/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
//  Cleanup
//  CGContextRelease(bitmapRef);
//  CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
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
