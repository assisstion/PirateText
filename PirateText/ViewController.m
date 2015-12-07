//
//  ViewController.m
//  PirateText
//
//  Created by Markus Feng on 9/30/15.
//  Copyright © 2015 Markus Feng. All rights reserved.
//

#import "ViewController.h"
#import "PirateConverter.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *inputText;
@property (weak, nonatomic) IBOutlet UITextView *outputText;
@property PirateConverter * converter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _converter = [[PirateConverter alloc] init];
    //Set the output text view to not editable
    _outputText.editable = false;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonConvert:(id)sender {
    //Hides the keyboard
    [_inputText resignFirstResponder];
    //Uses the pirate converter to convert the input text to the output text
    _outputText.text = [_converter convertFromEnglishToPirate:_inputText.text];
}

@end
