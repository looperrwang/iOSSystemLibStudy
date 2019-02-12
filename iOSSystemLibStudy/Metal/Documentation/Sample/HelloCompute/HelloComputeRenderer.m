/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class which performs Metal setup and per frame rendering
*/

#if TARGET_OS_IPHONE

@import simd;
@import MetalKit;

#import "HelloComputeRenderer.h"
#import "HelloComputeImage.h"

// Header shared between C code here, which executes Metal API commands, and .metal files, which
//   uses these types as inputs to the shaders
#import "HelloComputeShaderTypes.h"

// Main class performing the rendering
@implementation HelloComputeRenderer
{
    // The device (aka GPU) we're using to render
    id<MTLDevice> _device;

    // Our compute pipeline composed of our kernel defined in the .metal shader file
    id<MTLComputePipelineState> _computePipelineState;

    // Our render pipeline composed of our vertex and fragment shaders in the .metal shader file
    id<MTLRenderPipelineState> _renderPipelineState;

    // The command Queue from which we'll obtain command buffers
    id<MTLCommandQueue> _commandQueue;

    // Texture object which serves as the source for our image processing
    id<MTLTexture> _inputTexture;

    // Texture object which serves as the output for our image processing
    id<MTLTexture> _outputTexture;

    // The current size of our view so we can use this in our render pipeline
    vector_uint2 _viewportSize;

    // Compute kernel dispatch parameters
    MTLSize _threadgroupSize;
    MTLSize _threadgroupCount;
}

/// Initialize with the MetalKit view from which we'll obtain our Metal device
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        NSError *error = NULL;

        _device = mtkView.device;

        // Indicate we'll set the pixel format of  color texture to which we're drawing
        //   to the unsigned normalized RGBA8 pixel format
        mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;

        // Load all the shader files with a .metal file extension in the project
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

        // Load the kernel function from the library
        id<MTLFunction> kernelFunction = [defaultLibrary newFunctionWithName:@"grayscaleKernel"];

        // Create a compute pipeline state
        _computePipelineState = [_device newComputePipelineStateWithFunction:kernelFunction
                                                                       error:&error];

        if(!_computePipelineState)
        {
            // Compute pipeline State creation could fail if kernelFunction failed to load from the
            //   library.  If the Metal API validation is enabled, we automatically be given more
            //   information about what went wrong.  (Metal API validation is enabled by default
            //   when a debug build is run from Xcode)
            NSLog(@"Failed to create compute pipeline state, error %@", error);
            return nil;
        }

        // Load the vertex function from the library
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"HelloComputeVertexShader"];

        // Load the fragment function from the library
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"HelloComputeSamplingShader"];

        // Set up a descriptor for creating a pipeline state object
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Simple Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;

        _renderPipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        if (!_renderPipelineState)
        {
            NSLog(@"Failed to create render pipeline state, error %@", error);
        }

        NSURL *imageFileLocation = [[NSBundle mainBundle] URLForResource:@"HelloComputeImage"
                                                           withExtension:@"tga"];

        HelloComputeImage * image = [[HelloComputeImage alloc] initWithTGAFileAtLocation:imageFileLocation];

        if(!image)
        {
            return nil;
        }

        MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];

        // Indicate we're creating a 2D texture.
        textureDescriptor.textureType = MTLTextureType2D;

        // Indicate that each pixel has a Blue, Green, Red, and Alpha channel,
        //    each in an 8 bit unnormalized value (0 maps 0.0 while 255 maps to 1.0)
        textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
        textureDescriptor.width = image.width;
        textureDescriptor.height = image.height;
        textureDescriptor.usage = MTLTextureUsageShaderRead;

        // Create an input and output texture with similar descriptors.  We'll only
        //   fill in the inputTexture however.  And we'll set the output texture's descriptor
        //   to MTLTextureUsageShaderWrite
        _inputTexture = [_device newTextureWithDescriptor:textureDescriptor];

        textureDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead ;

        _outputTexture = [_device newTextureWithDescriptor:textureDescriptor];

        MTLRegion region = {{ 0, 0, 0 }, {textureDescriptor.width, textureDescriptor.height, 1}};

        // size of each texel * the width of the textures
        NSUInteger bytesPerRow = 4 * textureDescriptor.width;

        // Copy the bytes from our data object into the texture
        [_inputTexture replaceRegion:region
                    mipmapLevel:0
                      withBytes:image.data.bytes
                    bytesPerRow:bytesPerRow];

        if(!_inputTexture || error)
        {
            NSLog(@"Error creating texture %@", error.localizedDescription);
            return nil;
        }

        // Set the compute kernel's threadgroup size of 16x16
        _threadgroupSize = MTLSizeMake(16, 16, 1);

        // Calculate the number of rows and columns of threadgroups given the width of the input image
        // Ensure that you cover the entire image (or more) so you process every pixel
        _threadgroupCount.width  = (_inputTexture.width  + _threadgroupSize.width -  1) / _threadgroupSize.width;
        _threadgroupCount.height = (_inputTexture.height + _threadgroupSize.height - 1) / _threadgroupSize.height;

        // Since we're only dealing with a 2D data set, set depth to 1
        _threadgroupCount.depth = 1;

        // Create the command queue
        _commandQueue = [_device newCommandQueue];
    }

    return self;
}

/// Called whenever view changes orientation or is resized
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Save the size of the drawable as we'll pass these
    //   values to our vertex shader when we draw
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

/// Called whenever the view needs to render a frame
- (void)drawInMTKView:(nonnull MTKView *)view
{
    static const AAPLVertex quadVertices[] =
    {
        //Pixel Positions, Texture Coordinates
        { {  250,  -250 }, { 1.f, 0.f } },
        { { -250,  -250 }, { 0.f, 0.f } },
        { { -250,   250 }, { 0.f, 1.f } },

        { {  250,  -250 }, { 1.f, 0.f } },
        { { -250,   250 }, { 0.f, 1.f } },
        { {  250,   250 }, { 1.f, 1.f } },
    };

    // Create a new command buffer for each render pass to the current drawable
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];

    [computeEncoder setComputePipelineState:_computePipelineState];

    [computeEncoder setTexture:_inputTexture
                       atIndex:AAPLTextureIndexInput];

    [computeEncoder setTexture:_outputTexture
                       atIndex:AAPLTextureIndexOutput];

    [computeEncoder dispatchThreadgroups:_threadgroupCount
                   threadsPerThreadgroup:_threadgroupSize];

    [computeEncoder endEncoding];

    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil)
    {
        // Create a render command encoder so we can render into something
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";

        // Set the region of the drawable to which we'll draw.
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0 }];

        [renderEncoder setRenderPipelineState:_renderPipelineState];

        // We call -[MTLRenderCommandEncoder setVertexBytes:length:atIndex:] tp send data from our
        //   Application ObjC code here to our Metal 'vertexShader' function
        // This call has 3 arguments
        //   1) A pointer to the memory we want to pass to our shader
        //   2) The memory size of the data we want passed down
        //   3) An integer index which corresponds to the index of the buffer attribute qualifier
        //      of the argument in our 'vertexShader' function

        // Here we're sending a pointer to our 'triangleVertices' array (and indicating its size).
        //   The AAPLVertexInputIndexVertices enum value corresponds to the 'vertexArray' argument
        //   in our 'vertexShader' function because its buffer attribute qualifier also uses
        //   AAPLVertexInputIndexVertices for its index
        [renderEncoder setVertexBytes:quadVertices
                               length:sizeof(quadVertices)
                              atIndex:AAPLVertexInputIndexVertices];

        // Here we're sending a pointer to '_viewportSize' and also indicate its size so the whole
        //   think is passed into the shader.  The AAPLVertexInputIndexViewportSize enum value
        ///  corresponds to the 'viewportSizePointer' argument in our 'vertexShader' function
        //   because its buffer attribute qualifier also uses AAPLVertexInputIndexViewportSize
        //   for its index
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:AAPLVertexInputIndexViewportSize];

        [renderEncoder setFragmentTexture:_outputTexture
                                  atIndex:AAPLTextureIndexOutput];

        // Draw the vertices of our triangles
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:6];

        [renderEncoder endEncoding];

        // Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    // Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];
}

@end

#endif
