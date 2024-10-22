/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Particle Renderer's uniforms that are shared between Metal / Objective-C.
*/

#if TARGET_OS_IPHONE

#pragma once

#import <simd/simd.h>

#if METAL
#import <metal_stdlib>
using namespace metal;
#endif

#define MAX_PARTICLES (int)(4096*4)
#define PARTICLES_PER_THREADGROUP 128

struct ParticleInstanceBufferDescription
{
#ifdef METAL
    atomic_int numParticlesAlive;
    atomic_int firstParticleOffset;
#else
    int32_t numParticlesAlive;
    int32_t firstParticleOffset;
#endif
    int32_t particlesBufferSize;
};

struct ParticleSpawnParams
{
    int32_t         numParticles;
    simd::float2    invHeightMapSize;
    simd::float2    kernelOffset;
    float           cosAlpha;
    float           sinAlpha;
    float           radiusScale;
};

#endif

