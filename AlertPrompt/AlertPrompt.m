//
//  AlertPrompt.m
//  Prompt
//
//  Created by Jeff LaMarche on 2/26/09.

#import "AlertPrompt.h"

@implementation AlertPrompt

@synthesize textField;
@synthesize enteredText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle {
        
    if ((self = [super initWithTitle:title message:[NSString stringWithFormat:@"%@\n\n\n", message] delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])) {
        CGFloat textFieldY = [message sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(260, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height + 56 + 10;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) { textFieldY -= 20; }
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, textFieldY, 260.0, 25.0)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        theTextField.backgroundColor = [UIColor whiteColor]; 
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
    }
    return self;
}

- (void)show {
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText {
    return textField.text;
}

- (void)dealloc {
    [textField release];
    [super dealloc];
}

@end