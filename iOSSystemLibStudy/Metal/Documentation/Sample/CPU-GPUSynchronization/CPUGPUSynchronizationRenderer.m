/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering
*/

#if TARGET_OS_IPHONE

@import MetalKit;

#import "CPUGPUSynchronizationRenderer.h"

// Header shared between C code here, which executes Metal API commands, and .metal files, which
//   uses these types as inputs to the shaders
#import "CPUGPUSynchronizationShaderTypes.h"

// The max number of command buffers in flight
static const NSUInteger MaxBuffersInFlight = 3;

// A simple class representing our sprite object, which is just a colored quad on screen
@interface AAPLSprite : NSObject

@property (nonatomic) vector_float2 position;

@property (nonatomic) vector_float4 color;

+(const AAPLVertex*)vertices;

+(NSUInteger)vertexCount;

@end

@implementation AAPLSprite

// Return the vertices of one quad posistion at the origin.  After updating the
//   sprite's position each frame, we copy it to our vertex buffer
+(const AAPLVertex *)vertices
{
    const float SpriteSize = 5;
    static const AAPLVertex spriteVertices[] =
    {
        //Pixel Positions,                 RGBA colors
        { { -SpriteSize,   SpriteSize },   { 0, 0, 0, 1 } },
        { {  SpriteSize,   SpriteSize },   { 0, 0, 0, 1 } },
        { { -SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },

        { {  SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        { { -SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        { {  SpriteSize,   SpriteSize },   { 0, 0, 1, 1 } },
    };

    return spriteVertices;
}

// The number of vertices for each sprite
+(NSUInteger) vertexCount
{
    return 6;
}

@end

// Main class performing the rendering
@implementation CPUGPUSynchronizationRenderer
{
    dispatch_semaphore_t _inFlightSemaphore;
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;

    id<MTLRenderPipelineState> _pipelineState;
    id<MTLBuffer>              _vertexBuffers[MaxBuffersInFlight];

    // The current size of our view so we can use this in our render pipeline
    vector_uint2 _viewportSize;

    NSUInteger _currentBuffer;

    NSArray<AAPLSprite*> *_sprites;

    NSUInteger _spritesPerRow;
    NSUInteger _rowsOfSprites;
    NSUInteger _totalSpriteVertexCount;

}

/// Initialize with the MetalKit view from which we'll obtain our Metal device
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;

        _inFlightSemaphore = dispatch_semaphore_create(MaxBuffersInFlight);
        // Create and load our basic Metal state objects

        // Load all the shader files with a metal file extension in the project
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

        // Load the vertex function into the library
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"CPUGPUSynchronizationVertexShader"];

        // Load the fragment function into the library
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"CPUGPUSynchronizationfragmentShader"];

        // Create a reusable pipeline state
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"MyPipeline";
        pipelineStateDescriptor.sampleCount = mtkView.sampleCount;
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        pipelineStateDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat;
        pipelineStateDescriptor.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat;

        NSError *error = NULL;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
        if (!_pipelineState)
        {
            NSLog(@"Failed to created pipeline state, error %@", error);
        }
        // Create the command queue
        _commandQueue = [_device newCommandQueue];

        [self generateSprites];

        _totalSpriteVertexCount = AAPLSprite.vertexCount * _sprites.count;

        NSUInteger spriteVertexBufferSize = _totalSpriteVertexCount * sizeof(AAPLVertex);

        for(NSUInteger bufferIndex = 0; bufferIndex < MaxBuffersInFlight; bufferIndex++)
        {
            _vertexBuffers[bufferIndex] = [_device newBufferWithLength:spriteVertexBufferSize
                                                               options:MTLResourceStorageModeShared];
        }

    }

    return self;
}

/// Generate a list of sprites, initializing each and inserting it into `_sprites`.
- (void) generateSprites
{
    const float XSpacing = 12;
    const float YSpacing = 16;

    const NSUInteger SpritesPerRow = 110;
    const NSUInteger RowsOfSprites = 50;
    const float WaveMagnitude = 30.0;

    const vector_float4 Colors[] =
    {
        { 1.0, 0.0, 0.0, 1.0 },  // Red
        { 0.0, 1.0, 1.0, 1.0 },  // Cyan
        { 0.0, 1.0, 0.0, 1.0 },  // Green
        { 1.0, 0.5, 0.0, 1.0 },  // Orange
        { 1.0, 0.0, 1.0, 1.0 },  // Magenta
        { 0.0, 0.0, 1.0, 1.0 },  // Blue
        { 1.0, 1.0, 0.0, 1.0 },  // Yellow
        { .75, 0.5, .25, 1.0 },  // Brown
        { 1.0, 1.0, 1.0, 1.0 },  // White

    };

    const NSUInteger NumColors = sizeof(Colors) / sizeof(vector_float4);

    _spritesPerRow = SpritesPerRow;
    _rowsOfSprites = RowsOfSprites;

    NSMutableArray *sprites = [[NSMutableArray alloc] initWithCapacity:_rowsOfSprites * _spritesPerRow];

    // Create a grid of 'sprite' objects
    for(NSUInteger row = 0; row < _rowsOfSprites; row++)
    {
        for(NSUInteger column = 0; column < _spritesPerRow; column++)
        {
            vector_float2 spritePosition;

            // Determine the position of our sprite in the grid
            spritePosition.x = ((-((float)_spritesPerRow) / 2.0) + column) * XSpacing;
            spritePosition.y = ((-((float)_rowsOfSprites) / 2.0) + row) * YSpacing + WaveMagnitude;

            // Displace the height of this sprite using a sin wave
            spritePosition.y += (sin(spritePosition.x/WaveMagnitude) * WaveMagnitude);

            // Create our sprite, set its properties and add it to our list
            AAPLSprite * sprite = [AAPLSprite new];

            sprite.position = spritePosition;
            sprite.color = Colors[row%NumColors];

            [sprites addObject:sprite];
        }
    }
    _sprites = sprites;
}

/// Called whenever view changes orientation or is resized
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Save the size of the drawable as we'll pass these
    //   values to our vertex shader when we draw
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

/// Update the position of each sprite and also update vertices for each sprite in our buffer
- (void)updateState
{

    // Change the position of the sprites by getting taking on the height of the sprite
    //  immediately to the right of the current sprite.

    AAPLVertex *currentSpriteVertices = _vertexBuffers[_currentBuffer].contents;
    NSUInteger  currentVertex = _totalSpriteVertexCount-1;
    NSUInteger  spriteIdx = (_rowsOfSprites * _spritesPerRow)-1;

    for(NSInteger row = _rowsOfSprites - 1; row >= 0; row--)
    {
        float startY = _sprites[spriteIdx].position.y;
        for(NSInteger spriteInRow = _spritesPerRow-1; spriteInRow >= 0; spriteInRow--)
        {
            // Update the position of our sprite
            vector_float2 updatedPosition = _sprites[spriteIdx].position;

            if(spriteInRow == 0)
            {
                updatedPosition.y = startY;
            }
            else
            {
                updatedPosition.y = _sprites[spriteIdx-1].position.y;
            }

            _sprites[spriteIdx].position = updatedPosition;

            // Update vertices of the current vertex buffer with the sprites new position

            for(NSInteger vertexOfSprite = AAPLSprite.vertexCount-1; vertexOfSprite >= 0 ; vertexOfSprite--)
            {
                currentSpriteVertices[currentVertex].position = AAPLSprite.vertices[vertexOfSprite].position + _sprites[spriteIdx].position;
                currentSpriteVertices[currentVertex].color = _sprites[spriteIdx].color;
                currentVertex--;
            }
            spriteIdx--;
        }
    }
}

/// Called whenever the view needs to render
- (void)drawInMTKView:(nonnull MTKView *)view
{
    // Wait to ensure only MaxBuffersInFlight number of frames are getting proccessed
    //   by any stage in the Metal pipeline (App, Metal, Drivers, GPU, etc)
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);

    // Iterate through our Metal buffers, and cycle back to the first when we've written to MaxBuffersInFlight
    _currentBuffer = (_currentBuffer + 1) % MaxBuffersInFlight;

    // Update data in our buffers
    [self updateState];

    // Create a new command buffer for each render pass to the current drawable
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    // Add completion hander which signals _inFlightSemaphore when Metal and the GPU has fully
    //   finished processing the commands we're encoding this frame.  This indicates when the
    //   dynamic buffers filled with our vertices, that we're writing to this frame, will no longer
    //   be needed by Metal and the GPU, meaning we can overwrite the buffer contents without
    //   corrupting the rendering.
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
    {
        dispatch_semaphore_signal(block_sema);
    }];

    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil)
    {
        // Create a render command encoder so we can render into something
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";

        // Set render command encoder state
        [renderEncoder setCullMode:MTLCullModeBack];
        [renderEncoder setRenderPipelineState:_pipelineState];

        [renderEncoder setVertexBuffer:_vertexBuffers[_currentBuffer]
                               offset:0
                              atIndex:AAPLVertexInputIndexVertices];

        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:AAPLVertexInputIndexViewportSize];

        // Draw the vertices of our quads
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:_totalSpriteVertexCount];

        // We're done encoding commands
        [renderEncoder endEncoding];

        // Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    // Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];
}

@end

#endif
