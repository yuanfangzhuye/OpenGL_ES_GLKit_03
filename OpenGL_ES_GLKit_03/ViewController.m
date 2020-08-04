//
//  ViewController.m
//  OpenGL_ES_GLKit_03
//
//  Created by 李超 on 2020/8/4.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) GLKBaseEffect *mEffect;

@property (nonatomic, assign) int count;

//旋转的度数
@property(nonatomic,assign)float XDegree;
@property(nonatomic,assign)float YDegree;
@property(nonatomic,assign)float ZDegree;

//是否旋转X,Y,Z
@property(nonatomic,assign) BOOL XB;
@property(nonatomic,assign) BOOL YB;
@property(nonatomic,assign) BOOL ZB;

@end

@implementation ViewController
{
    dispatch_source_t timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupContext];
    [self render];
}

- (void)setupContext
{
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.mContext) {
        return;
    }
    
    GLKView *kView = (GLKView *)self.view;
    kView.context = self.mContext;
    kView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    kView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    
    glEnable(GL_DEPTH_TEST);
}

- (void)render
{
    //1.
    GLfloat attrArr[] = {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f,       0.0f, 0.0f,//左下

        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f,       0.5f, 0.5f,//顶点
    };
    
    //2.绘图索引
    GLuint indices[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    self.count = sizeof(indices)/sizeof(GLuint);
    
    //顶点缓存区
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    //索引缓存区
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 6);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"timg" ofType:@"png"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"1", GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *tetureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = tetureInfo.name;
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 100.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2);
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    double seconds = 0.1f;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        self.XDegree += 0.1f * self.XB;
        self.YDegree += 0.1f * self.YB;
        self.ZDegree += 0.1f * self.ZB;
    });
    
    dispatch_resume(timer);
}

- (void)update
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2.5f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.XDegree);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.YDegree);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.ZDegree);
    
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.mEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
}

- (IBAction)xClick:(id)sender {
    
    _XB = !_XB;
}
- (IBAction)yClick:(id)sender {
    
    _YB = !_YB;
}
- (IBAction)zClick:(id)sender {
    
    _ZB = !_ZB;
}

@end
