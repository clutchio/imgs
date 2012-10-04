//
// Copyright 2012 Twitter
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CommentController.h"

NSString * const TEXT_DEFAULT = @"Enter a comment (optional)";

@implementation CommentController

@synthesize image = _image;
@synthesize bkg = _bkg;
@synthesize callbackBlock = _callbackBlock;
@synthesize textView = _textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)sendComment
{
    // Trim out all the whitespace from their comment
    NSString *cleanedText = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Don't let them submit the placeholder comment as their comment
    if([cleanedText isEqualToString:TEXT_DEFAULT]) {
        return;
    }
    if([cleanedText isEqualToString:@""]) {
        return;
    }
    
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    [comment setObject:[self.image objectForKey:@"hash"] forKey:@"hash"];
    [comment setObject:[PFUser currentUser] forKey:@"user"];
    [comment setObject:cleanedText forKey:@"text"];
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"text", nil];
            self.callbackBlock(params);
            self.callbackBlock = nil;
            [self dismissModalViewControllerAnimated:YES];
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" 
                                                        message:@"It appears there was an error saving your comment, please try again." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }];
}

- (void)cancelTapped
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([textView.text isEqualToString:TEXT_DEFAULT]) {
        textView.text = @"";
        textView.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    if (![text isEqualToString:@"\n"]) {
		return TRUE;
    }
	[textView resignFirstResponder];
    [self sendComment];
    return FALSE;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([textView.text isEqualToString:@""]) {
        textView.text = TEXT_DEFAULT;
        textView.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
        textView.selectedRange = NSMakeRange(0, 0);
    }
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg.png"]];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setBackgroundImage:[UIImage imageNamed:@"top-bar-blank.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendComment)];
    NSArray *buttons = [NSArray arrayWithObjects:cancelButton, spacer, saveButton, nil];
    [toolbar setItems:buttons];
    [self.view addSubview:toolbar];
    [saveButton release];
    [spacer release];
    [cancelButton release];
    [toolbar release];
    
    self.bkg = [[UIView alloc] initWithFrame:CGRectMake(14, 54, 294, 120)];
    [self.bkg release];
    self.bkg.backgroundColor = [UIColor whiteColor];
    self.bkg.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.8].CGColor;
    self.bkg.layer.borderWidth = 8.0f;
    self.bkg.layer.cornerRadius = 6.0f;
    [self.view addSubview:self.bkg];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(23, 63, 276, 102)];
    [self.textView release];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.clipsToBounds = YES;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.delegate = self;
    self.textView.text = TEXT_DEFAULT;
    self.textView.selectedRange = NSMakeRange(0, 0);
    [self.view addSubview:self.textView];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.image = nil;
    self.bkg = nil;
    self.callbackBlock = nil;
    self.textView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
