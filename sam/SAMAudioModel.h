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
#import "SAMEditViewController.h"

#include "FFTManager.h"

@interface SAMAudioModel : NSObject
{    
    // FFT Properties
    int windowSize;
    int overlap;
    int hopSize;
    
    float normalizationFactor;
    int numFramesInAudioFile;
    int numFFTFrames;
    float *audioBuffer;
    
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
    
    NSMutableArray* shapeReferences;
    
    // Circular Buffer thingy
    //BUFFER_MANAGER* overlapBuffer;
    //BUFFER* currentBuffer;
    
    // Polar window buffers
    POLAR_WINDOW* polarWindows[2];
    int currentPolar;
    
    //-------------------------------
    BOOL fileLoaded;
}

@property int windowSize;
@property int overlap;
@property int numFFTFrames;
@property int screenWidth;
@property int screenHeight;

@property (readonly) STFT_BUFFER* stftBuffer;

+ (SAMAudioModel *)sharedAudioModel;
- (void)openAudioFile:(CFURLRef)fileToOpen;
- (void)calculateSTFT;

//
- (void)setShapeReference:(NSMutableArray *)shapeRef;

// Audio Playback (aka DAC) On/Off
- (void)startAudioPlayback;
- (void)stopAudioPlayback;

@end
