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
#include "Voice.h"
#include <stdlib.h>

#define TOUCH_DIVIDE 100                // this is used in a scaling operation
#define TOUCH_HIGHEND_CUT 1
#define MAX_VOICES 10                   // 10 is probably too many, but keep it there for now

# pragma mark - C Functions -

enum PLAYBACK_MODE
{
    FORWARD_MODE = 0,
    AVERAGE_MODE = 1
};


# pragma mark - Main Interface -

@interface SAMAudioModel : NSObject
{
    // FFT Properties
    int windowSize;
    int halfWindowSize;
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
    
    // Audio units and graphs
    AudioUnit samUnit;
    AudioUnit iOUnit;
    AUGraph   processingGraph;
    
    FFT* fftManager;
    STFT_BUFFER* stftBuffer;
    
    float* circleBuffer[4];
    float* outputBuffer;
    
    int counter;
    int rate;
    int rateCounter;
    
    // Polar window buffers
    POLAR_WINDOW* polarWindows[3];
    int currentPolar;
    
    POLAR_WINDOW* pastWindow;
    
    //-------------------------------
    BOOL        fileLoaded;
    CGRect      editArea;
//    float       touchScale;             // scale value used in touch mapping
    
    FFT_FRAME*  fftFrameBuffer[2];
    int         whichFrame;
    float*      lpIn;
    float*      lpOut;
    int         hopPosition;
    
    //--
    float top, topNext;
    float bottom, bottomNext;
    
    enum PLAYBACK_MODE mode;
    
    RegionPolygon* shapeReferences[MAX_VOICES];         // numberOfVoices corresponds to which slots are filled in
    VOICE* voiceReferences[MAX_VOICES];
    
    BOOL inProcessingLoop;
    
    
    // Recording stuff
    CFURLRef fileUrl;
    NSString* documentsDirectory;
    ExtAudioFileRef recordingAudioFileRef;
}

@property int windowSize;
@property int overlap;
@property int numFFTFrames;
@property int screenWidth;
@property int screenHeight;
@property CGRect editArea;
@property BOOL monitor;
@property enum PLAYBACK_MODE mode;
@property float touchScale;
@property int numberOfVoices;
@property int stftBufferSize;

@property (nonatomic, weak) RegionPolygon* poly;
@property (readonly) STFT_BUFFER* stftBuffer;
@property BOOL isRecording;

+ (SAMAudioModel *)sharedAudioModel;
- (void)openAudioFile:(CFURLRef)fileToOpen;
- (BOOL)calculateSTFT;

//
- (void)addShape:(RegionPolygon *)shapeReference;
- (void)removeShape:(RegionPolygon *)shapeReference;

// Audio Playback (aka DAC) On/Off
- (void)startAudioPlayback;
- (void)stopAudioPlayback;

// recording
- (void)startRecording;
- (void)stopRecording;

@end
