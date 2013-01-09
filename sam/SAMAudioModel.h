//
//  SAMAudioModel.h
//  SAM
//
//  Created by Scott McCoid on 10/22/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#import <GLKit/GLKit.h>
#include "FFTManager.h"
#include "Pvoc.h"

@interface SAMAudioModel : NSObject
{
    float *audioBuffer;
    float normalizationFactor;
    
    int windowSize;
    int overlap;
    int numFramesInAudioFile;
    int numFFTFrames;
    int hopSize;
    
    // DSP tick
    int numberOfDSPTicks;       // This is the number of DSP Ticks
    int dspTick;                // This is the current DSP tick
    int modAmount;
    
    // Appwide settings
    Float32 blockSize;
    Float32 sampleRate;
    
    AudioUnit samUnit;
    
    FFT* fftManager;
    STFT_BUFFER* stftBuffer;
    
    float* circleBuffer[2];
    float* outputBuffer;
    
    int counter;
    int rate;
    int rateCounter;
    
    
    // Circular Buffer thingy
    //BUFFER_MANAGER* overlapBuffer;
    //BUFFER* currentBuffer;
    
    // Polar window buffers
    POLAR_WINDOW* polarWindows[2];
    int currentPolar;
    
    
    int leftBound;
    int rightBound;
    int topBound;
    int bottomBound;
    
    int screenWidth;
    int screenHeight;
    
    int playbackLeft;
    int playbackRight;
    int playbackTop;
    int playbackBottom;
}

@property int windowSize;
@property int overlap;
//@property (readonly) float *frequencyBuffer;
@property (readonly) STFT_BUFFER* stftBuffer;
@property int numFFTFrames;
@property int screenWidth;
@property int screenHeight;

+ (SAMAudioModel *)sharedAudioModel;
- (void)openAudioFile:(CFURLRef)fileToOpen;
- (void)calculateSTFT;
- (void)startAudioSession;
- (void)setBounds:(GLKVector2)_leftBound andRight:(GLKVector2)_rightBound;

@end
