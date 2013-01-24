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

#define TOUCH_DIVIDE 100                // this is used in a scaling operation
#define TOUCH_HIGHEND_CUT 1.5

# pragma mark - C Functions -

float changeTouchYScale(float inputPoint, float scale);
void render(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData);
void pva(FFT_FRAME* frame, int sampleRate, int hopSize)


# pragma mark - Main Interface -

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
    BOOL        fileLoaded;
    CGRect      editArea;
    float       touchScale;             // scale value used in touch mapping
    
    FFT_FRAME*  fftFrameBuffer[2];
    int         whichFrame;
}

@property int windowSize;
@property int overlap;
@property int numFFTFrames;
@property int screenWidth;
@property int screenHeight;
@property CGRect editArea;

@property (nonatomic, weak) RegionPolygon* poly;

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
