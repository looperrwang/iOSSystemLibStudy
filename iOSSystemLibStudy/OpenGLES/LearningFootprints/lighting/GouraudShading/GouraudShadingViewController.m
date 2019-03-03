//
//  GouraudShadingViewController.m
//  iOSSystemLibStudy
//
//  Created by looperwang on 2019/2/17.
//  Copyright © 2019 looperwang. All rights reserved.
//

#import "GouraudShadingViewController.h"
#import "GouraudShadingRenderer.h"

@interface GouraudShadingViewController ()

@property (nonatomic, strong) GouraudShadingRenderer *renderer;

@end

@implementation GouraudShadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"GouraudShading";
    
    UILabel *ambientStrengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    ambientStrengthLabel.text = @"ambientStrength:";
    ambientStrengthLabel.textColor = [UIColor whiteColor];
    ambientStrengthLabel.textAlignment = NSTextAlignmentRight;
    
    UISlider *ambientStrengthSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [ambientStrengthSlider addTarget:self action:@selector(onAmbientStrengthChanged:) forControlEvents:UIControlEventValueChanged];
    ambientStrengthSlider.minimumValue = 0.0f;
    ambientStrengthSlider.maximumValue = 1.0f;
    ambientStrengthSlider.value = 0.1f;
    
    UILabel *diffuseStrengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    diffuseStrengthLabel.text = @"diffuseStrength:";
    diffuseStrengthLabel.textColor = [UIColor whiteColor];
    diffuseStrengthLabel.textAlignment = NSTextAlignmentRight;
    
    UISlider *diffuseStrengthSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [diffuseStrengthSlider addTarget:self action:@selector(onDiffuseStrengthChanged:) forControlEvents:UIControlEventValueChanged];
    diffuseStrengthSlider.minimumValue = 0.0f;
    diffuseStrengthSlider.maximumValue = 1.0f;
    diffuseStrengthSlider.value = 1.0f;
    
    UILabel *specularStrengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    specularStrengthLabel.text = @"specularStrength:";
    specularStrengthLabel.textColor = [UIColor whiteColor];
    specularStrengthLabel.textAlignment = NSTextAlignmentRight;
    
    UISlider *specularStrengthSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [specularStrengthSlider addTarget:self action:@selector(onSpecularStrengthChanged:) forControlEvents:UIControlEventValueChanged];
    specularStrengthSlider.minimumValue = 0.0f;
    specularStrengthSlider.maximumValue = 1.0f;
    specularStrengthSlider.value = 0.5f;
    
    UILabel *coefficientLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    coefficientLabel.text = @"coefficient:";
    coefficientLabel.textColor = [UIColor whiteColor];
    coefficientLabel.textAlignment = NSTextAlignmentRight;
    
    UISlider *coefficientSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [coefficientSlider addTarget:self action:@selector(onCoefficientChanged:) forControlEvents:UIControlEventValueChanged];
    coefficientSlider.minimumValue = 32.0f;
    coefficientSlider.maximumValue = 512.0f;
    coefficientSlider.value = 32.0f;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 10, 10, 10);
    CGSize ambientStrengthSize = [ambientStrengthLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)];
    CGSize diffuseStrengthSize = [diffuseStrengthLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)];
    CGSize specularStrengthSize = [specularStrengthLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)];
    CGSize coefficientSize = [coefficientLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)];
    
    CGFloat maxWidth = ambientStrengthSize.width;
    if (diffuseStrengthSize.width > maxWidth) maxWidth = diffuseStrengthSize.width;
    if (specularStrengthSize.width > maxWidth) maxWidth = specularStrengthSize.width;
    if (coefficientSize.width > maxWidth) maxWidth = coefficientSize.width;
    
    CGFloat maxHeight = ambientStrengthSize.height;
    if (diffuseStrengthSize.height > maxHeight) maxHeight = diffuseStrengthSize.height;
    if (specularStrengthSize.height > maxHeight) maxHeight = specularStrengthSize.height;
    if (coefficientSize.height > maxHeight) maxHeight = coefficientSize.height;
    
    coefficientLabel.frame = CGRectMake(edgeInsets.left, [UIScreen mainScreen].bounds.size.height - edgeInsets.bottom - maxHeight * 2, maxWidth, maxHeight);
    coefficientSlider.frame = CGRectMake(coefficientLabel.frame.origin.x + coefficientLabel.frame.size.width + 10, coefficientLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width - edgeInsets.left - edgeInsets.right - coefficientLabel.frame.size.width - 10, coefficientLabel.frame.size.height);
    
    specularStrengthLabel.frame = CGRectMake(edgeInsets.left, [UIScreen mainScreen].bounds.size.height - edgeInsets.bottom - 2 * maxHeight * 2, maxWidth, maxHeight);
    specularStrengthSlider.frame = CGRectMake(specularStrengthLabel.frame.origin.x + specularStrengthLabel.frame.size.width + 10, specularStrengthLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width - edgeInsets.left - edgeInsets.right - specularStrengthLabel.frame.size.width - 10, specularStrengthLabel.frame.size.height);
    
    diffuseStrengthLabel.frame = CGRectMake(edgeInsets.left, [UIScreen mainScreen].bounds.size.height - edgeInsets.bottom - 3 * maxHeight * 2, maxWidth, maxHeight);
    diffuseStrengthSlider.frame = CGRectMake(diffuseStrengthLabel.frame.origin.x + diffuseStrengthLabel.frame.size.width + 10, diffuseStrengthLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width - edgeInsets.left - edgeInsets.right - diffuseStrengthLabel.frame.size.width - 10, diffuseStrengthLabel.frame.size.height);
    
    ambientStrengthLabel.frame = CGRectMake(edgeInsets.left, [UIScreen mainScreen].bounds.size.height - edgeInsets.bottom - 4 * maxHeight * 2, maxWidth, maxHeight);
    ambientStrengthSlider.frame = CGRectMake(ambientStrengthLabel.frame.origin.x + ambientStrengthLabel.frame.size.width + 10, ambientStrengthLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width - edgeInsets.left - edgeInsets.right - ambientStrengthLabel.frame.size.width - 10, ambientStrengthLabel.frame.size.height);
    
    [self.view addSubview:ambientStrengthLabel];
    [self.view addSubview:ambientStrengthSlider];
    [self.view addSubview:diffuseStrengthLabel];
    [self.view addSubview:diffuseStrengthSlider];
    [self.view addSubview:specularStrengthLabel];
    [self.view addSubview:specularStrengthSlider];
    [self.view addSubview:coefficientLabel];
    [self.view addSubview:coefficientSlider];
    
    _renderer.ambientStrength = ambientStrengthSlider.value;
    _renderer.diffuseStrength = diffuseStrengthSlider.value;
    _renderer.specularStrength = specularStrengthSlider.value;
    _renderer.coefficient = coefficientSlider.value;
}

- (void)onAmbientStrengthChanged:(UISlider *)slider
{
    _renderer.ambientStrength = slider.value;
}

- (void)onDiffuseStrengthChanged:(UISlider *)slider
{
    _renderer.diffuseStrength = slider.value;
}

- (void)onSpecularStrengthChanged:(UISlider *)slider
{
    _renderer.specularStrength = slider.value;
}

- (void)onCoefficientChanged:(UISlider *)slider
{
    _renderer.coefficient = slider.value;
}

- (EAGLRenderer *)renderer
{
    if (!_renderer) {
        _renderer = [[GouraudShadingRenderer alloc] init];
    }
    
    return _renderer;
}

@end
