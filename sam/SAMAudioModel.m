//
//  SAMAudioModel.m
//  SAM
//
//  Created by Scott McCoid on 10/22/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "SAMAudioModel.h"
#define PI 3.14159265359
#define TWO_PI (2 * PI)

@implementation SAMAudioModel

@synthesize windowSize;
@synthesize overlap;
//@synthesize frequencyBuffer;
@synthesize stftBuffer;
@synthesize numFFTFrames;


#pragma mark - Render Callback -
static OSStatus renderCallback(void *inRefCon, 
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList *ioData)
{
    // Get a reference to this audio model
    SAMAudioModel* this = (__bridge SAMAudioModel *)inRefCon;
    Float32 *buffer = (Float32 *)ioData->mBuffers[0].mData;
    
    // Reference to STFT buffer
    STFT_BUFFER* thisSTFTBuffer = this->stftBuffer;
    
//    float fac, scale, delta;
//    fac = (float) (this->hopSize * TWO_PI / this->sampleRate);
//    scale = this->sampleRate / this->windowSize;
    
    if (NO)
    {
        // ------------------------------------------------------------------------------------
        if (this->dspTick == 0)
        {
            FFT_FRAME* frame = thisSTFTBuffer->buffer[this->counter];
            memcpy(frame->polarWindowMod, frame->polarWindow, sizeof(POLAR_WINDOW));
            this->polarWindows[this->currentPolar] = frame->polarWindowMod;
        
            // try zeroing out stuff
            for (int w = 0; w < this->windowSize / 2; w++)
            {
//                if (w > this->playbackBottom || w < this->playbackTop)              
//                {
//                    this->polarWindows[this->currentPolar]->buffer[w].mag = 0.0;
//                    this->polarWindows[this->currentPolar]->buffer[w].phase = 0.0;
//                }
            }
        
            pvUnwrapPhase(this->polarWindows[this->currentPolar]);
            pvFixPhase(this->polarWindows[!this->currentPolar], this->polarWindows[this->currentPolar], 0.5);
            inverseFFT(this->fftManager, frame, this->circleBuffer[0]);
                
            // shift and overlap add new buffer
            int diff = this->windowSize - this->hopSize;
            for (int i = 0; i < diff; i++)
                this->circleBuffer[1][i] = this->circleBuffer[1][diff + i] + this->circleBuffer[0][i];
                //this->circleBuffer[1][i] = this->circleBuffer[1][diff + i] + this->circleBuffer[0][(i + this->modAmount) % this->windowSize];
        
            // assign remaining values to playback buffer
            for (int i = 0; i < this->hopSize; i++)
                this->circleBuffer[1][diff + i] = this->circleBuffer[0][diff + i];
        
            this->currentPolar = !this->currentPolar;
        }
    
        for (int frameCounter = 0; frameCounter < inNumberFrames; frameCounter++)
        {   
            buffer[frameCounter] = this->circleBuffer[1][frameCounter + this->dspTick];
            //printf("%f\n", buffer[frameCounter]);
        }
    
        // ------------------------------------------------------------------------------------
        // Deal with progressing time / dsp ticks
        this->dspTick += inNumberFrames; 
        this->modAmount = (this->modAmount + inNumberFrames) % this->windowSize;
    
        if (this->dspTick >= this->hopSize)
        {
            this->dspTick = 0;
        
            if (this->rateCounter % this->rate == 0)
                this->counter++;
        
            this->rateCounter++;
        }
//        if (this->counter >= this->playbackRight)
//            this->counter = this->playbackLeft;
    }
   
    return noErr;
}

#pragma mark - Static Model Method -

+ (SAMAudioModel *)sharedAudioModel
{
    static SAMAudioModel *sharedAudioModel = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedAudioModel = [[SAMAudioModel alloc] init];
    });
    
    return sharedAudioModel;
}

#pragma mark - Initialization -

- (id)init
{
    self = [super init];
    
    if (self)
    {
        windowSize = 1024;
        overlap = 2;
        hopSize = windowSize / overlap;
        audioBuffer = nil;        
        normalizationFactor = 0.0;
        counter = 0;
        rate = 4;
        rateCounter = 0;
        
        // Appwide AU settings
        blockSize = 512;
        sampleRate = 44100;
        
        // DSP Tick Business
        numberOfDSPTicks = hopSize / blockSize;          // This better be an integer...
        dspTick = 0;                                        // Always start off on 0
        modAmount = 0;//numberOfDSPTicks / overlap;
        
        // Allocate memory and initialize fft manager
        fftManager = newFFT(windowSize);
        NSAssert(fftManager != NULL, @"Error creating fft manager.");
        
        stftBuffer = nil;
        
        // Setup an audio session
        [self setupAudioSession];
        
        // Setup/initialize an audio unit
        [self setupAudioUnit];
        
        circleBuffer[0] = (float *)malloc(windowSize * sizeof(float));
        circleBuffer[1] = (float *)malloc(windowSize * sizeof(float));
        
        // Circular Buffer thingy
        //overlapBuffer = createBufferManager(overlap, windowSize);
        
        // Polar window buffers
        polarWindows[0] = newPolarWindow(windowSize / 2);
        polarWindows[1] = newPolarWindow(windowSize / 2);
        currentPolar = 0;
        
        
        //-----------------------------------------------
        fileLoaded = NO;
        shapeReferences = nil;
    }
    
    return self;
}


#pragma mark - Dealloc -

- (void)dealloc
{
    if (samUnit)
    {
        AudioOutputUnitStop(samUnit);
        AudioUnitUninitialize(samUnit);
        AudioComponentInstanceDispose(samUnit);
        samUnit = nil;
    }
    
    free(audioBuffer);
    free(outputBuffer);
    free(circleBuffer[0]);
    free(circleBuffer[1]);
    
    // Free fft stuff and instance
    freeFFT(fftManager);
    
    // Free stft buffer
    freeSTFTBuffer(stftBuffer);
    
    // Free buffer manager / overlap buffer
    //freeBufferManager(overlapBuffer);
    
    freePolarWindow(polarWindows[0]);
    freePolarWindow(polarWindows[1]);
}


#pragma mark - Audio Unit Init -

- (void)setupAudioSession
{
    OSStatus status;
    Float32 bufferDuration = (blockSize + 0.5) / sampleRate;           // TODO: add 0.5 to blockSize?
    UInt32 category = kAudioSessionCategory_MediaPlayback;
    
    status = AudioSessionInitialize(NULL, NULL, NULL, (__bridge void *)self);
    status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    status = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(sampleRate), &sampleRate);
    status = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(bufferDuration), &bufferDuration);
    status = AudioSessionSetActive(true);
    
    //--------- Check everything
    Float64 audioSessionProperty64 = 0;
    Float32 audioSessionProperty32 = 0;
    UInt32 audioSessionPropertySize64 = sizeof(audioSessionProperty64);
    UInt32 audioSessionPropertySize32 = sizeof(audioSessionProperty32);
    
    status = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &audioSessionPropertySize64, &audioSessionProperty64);
    NSLog(@"AudioSession === CurrentHardwareSampleRate: %.0fHz", audioSessionProperty64);
    
    sampleRate = audioSessionProperty64;
    
    status = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &audioSessionPropertySize32, &audioSessionProperty32);
    int blockSizeCheck = lrint(audioSessionProperty32 * audioSessionProperty64);
    NSLog(@"AudioSession === CurrentHardwareIOBufferDuration: %3.2fms", audioSessionProperty32*1000.0f);
    NSLog(@"AudioSession === block size: %i", blockSizeCheck);
    
}

- (void)setupAudioUnit
{
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Find and assign default output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"-- Can't find a default output. --");
    
    // Create new audio unit that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &samUnit);
    NSAssert1(samUnit, @"Error creating unit: %hd", err);
    
    // Enable IO for playback
    UInt32 flag = 1;
    err = AudioUnitSetProperty(samUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &flag, sizeof(flag));
    NSAssert1(err == noErr, @"Error setting output IO", err);
    
    // set format to 32 bit, single channel, floating point, linear PCM
    const int fourBytesPerFloat = 4;
    const int eightBitsPerByte = 8;
    
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate =       44100;
    streamFormat.mFormatID =         kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =      kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket =   fourBytesPerFloat;
    streamFormat.mFramesPerPacket =  1;
    streamFormat.mBytesPerFrame =    fourBytesPerFloat;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel =   fourBytesPerFloat * eightBitsPerByte;
    
    err = AudioUnitSetProperty(samUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
    
    // Output 
    // Setup rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = renderCallback;
    input.inputProcRefCon = (__bridge void *)self;
    err = AudioUnitSetProperty(samUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, 0, &input, sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);
    
}



#pragma mark - Public Methods -

- (void)openAudioFile:(CFURLRef)fileToOpen
{
    // Create OSStatus
    OSStatus result;
    
    // Create audio file object
    ExtAudioFileRef audioFileObject = 0;
    
    // Open audio file
    result = ExtAudioFileOpenURL(fileToOpen, &audioFileObject);
    assert(result == noErr);
    
    // Get the audio file's length in frames.
    UInt64 totalFramesInFile = 0;
    UInt32 frameLengthPropertySize = sizeof(totalFramesInFile);
    
    result = ExtAudioFileGetProperty (audioFileObject, kExtAudioFileProperty_FileLengthFrames, &frameLengthPropertySize, &totalFramesInFile);
    assert(result == noErr);
    numFramesInAudioFile = totalFramesInFile;
    
    // Get the audio file's number of channels.
    AudioStreamBasicDescription fileAudioFormat = {0};
    UInt32 formatPropertySize = sizeof (fileAudioFormat);
    
    result = ExtAudioFileGetProperty(audioFileObject, kExtAudioFileProperty_FileDataFormat, &formatPropertySize, &fileAudioFormat);
    assert(result == noErr);
    
    //    UInt32 channelsPerFrame = fileAudioFormat.mChannelsPerFrame;
    UInt32 channelCount = fileAudioFormat.mChannelsPerFrame;
    
    // allocate temporary channel buffers
    AudioUnitSampleType* leftBuffer = calloc(numFramesInAudioFile, sizeof(AudioUnitSampleType));
    AudioUnitSampleType* rightBuffer = NULL;
    if (channelCount == 2)
        rightBuffer = calloc(numFramesInAudioFile, sizeof(AudioUnitSampleType));

    // create / reallocate reused variables
    [self createBuffers];
    
    AudioStreamBasicDescription importFormat = {0};
    
    if (channelCount == 2)
    {
        size_t bytesPerSample = sizeof (AudioUnitSampleType);
        
        // Fill the application audio format struct's fields to define a linear PCM, 
        //        stereo, noninterleaved stream at the hardware sample rate.
        importFormat.mFormatID          = kAudioFormatLinearPCM;
        importFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
        importFormat.mBytesPerPacket    = bytesPerSample;
        importFormat.mFramesPerPacket   = 1;
        importFormat.mBytesPerFrame     = bytesPerSample;
        importFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
        importFormat.mBitsPerChannel    = 8 * bytesPerSample;
        importFormat.mSampleRate        = 44100;
    }
    else
    {
        size_t bytesPerSample = sizeof (AudioUnitSampleType);
        
        // Fill the application audio format struct's fields to define a linear PCM, 
        //        stereo, noninterleaved stream at the hardware sample rate.
        importFormat.mFormatID          = kAudioFormatLinearPCM;
        importFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
        importFormat.mBytesPerPacket    = bytesPerSample;
        importFormat.mFramesPerPacket   = 1;
        importFormat.mBytesPerFrame     = bytesPerSample;
        importFormat.mChannelsPerFrame  = 1;                    // 2 indicates stereo
        importFormat.mBitsPerChannel    = 8 * bytesPerSample;
        importFormat.mSampleRate        = 44100;
    }
    
    
    // Assign the appropriate mixer input bus stream data format to the extended audio 
    //        file object. This is the format used for the audio data placed into the audio 
    //        buffer in the SoundStruct data structure, which is in turn used in the 
    //        inputRenderCallback callback function.
    result = ExtAudioFileSetProperty (audioFileObject, kExtAudioFileProperty_ClientDataFormat, sizeof(importFormat), &importFormat);
    assert(result == noErr);
    
    
    // Set up an AudioBufferList struct, which has two roles:
    //
    //        1. It gives the ExtAudioFileRead function the configuration it 
    //            needs to correctly provide the data to the buffer.
    //
    //        2. It points to the soundStructArray[audioFile].audioDataLeft buffer, so 
    //            that audio data obtained from disk using the ExtAudioFileRead function
    //            goes to that buffer
    
    // Allocate memory for the buffer list struct according to the number of 
    //    channels it represents.
    AudioBufferList *bufferList;
    bufferList = (AudioBufferList *) malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * (channelCount - 1));
    
    // initialize the mNumberBuffers member
    bufferList->mNumberBuffers = channelCount;
    
    // initialize the mBuffers member to 0
    AudioBuffer emptyBuffer = {0};
    size_t arrayIndex;
    for (arrayIndex = 0; arrayIndex < channelCount; arrayIndex++) {
        bufferList->mBuffers[arrayIndex] = emptyBuffer;
    }
    
    // set up the AudioBuffer structs in the buffer list
    bufferList->mBuffers[0].mNumberChannels  = 1;
    bufferList->mBuffers[0].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
    bufferList->mBuffers[0].mData            = leftBuffer;
    
    if (channelCount == 2) {
        bufferList->mBuffers[1].mNumberChannels  = 1;
        bufferList->mBuffers[1].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
        bufferList->mBuffers[1].mData            = rightBuffer;
    }
    
    
    UInt32 numberOfPacketsToRead = (UInt32)totalFramesInFile;
    result = ExtAudioFileRead (audioFileObject, &numberOfPacketsToRead, bufferList);
    free (bufferList);
    
    // Dispose of the extended audio file object, which also
    //    closes the associated file.
    ExtAudioFileDispose (audioFileObject);
    
    // Convert to floating point format
    [self convert:leftBuffer withSize:totalFramesInFile];
    
    // If stereo convert right channel to float then convert to mono
    if (channelCount == 2)
    {
        [self convert:rightBuffer withSize:totalFramesInFile];
        [self convertToMonoWith:(float *)leftBuffer andRightChannel:(float *)rightBuffer withSize:totalFramesInFile];
    }
    
    // Copy over samples from leftbuffer to main audio buffer
    memcpy(audioBuffer, leftBuffer, numFramesInAudioFile * sizeof(float));
    
    free(leftBuffer);
    if (rightBuffer != NULL)
        free(rightBuffer);
}


#pragma mark - Utility Methods -
// This method creates a mono track and stuffs it into the left channel
- (void)convertToMonoWith:(float *)left andRightChannel:(float *)right withSize:(int)size
{
    for (int i = 0; i < size; i++)
        left[i] = (left[i] + right[i]) / 2.0;
}

// Converts from AudioUnit sample type to float
//- (void)convert:(AudioUnitSampleType *)input to:(float *)output withSize:(int)size
- (void)convert:(AudioUnitSampleType *)input withSize:(int)size
{
    for (int i = 0; i < size; i++)
        input[i] = (float)((SInt16)(input[i] >> 9) / 32768.0);
}

- (void)createBuffers
{
    if (audioBuffer == nil)
    {
        audioBuffer = (float *)malloc(numFramesInAudioFile * sizeof(float));
        outputBuffer = (float *)malloc(numFramesInAudioFile * sizeof(float));
    }
    else
    {
        realloc(audioBuffer, numFramesInAudioFile * sizeof(float));
        realloc(outputBuffer, numFramesInAudioFile * sizeof(float));
    }
    
    if (stftBuffer != nil)
        free(stftBuffer);
    
    stftBuffer = newSTFTBuffer(windowSize, overlap, &numFFTFrames, numFramesInAudioFile);
}

#pragma mark - Public Methods -

- (void)calculateSTFT
{
    computeSTFT(fftManager, stftBuffer, audioBuffer);
}

- (void)setShapeReference:(NSMutableArray *)shapeRef
{
    shapeReferences = shapeRef;
}

- (void)startAudioPlayback
{
    AudioSessionSetActive(true);
    
    // Start playback
    OSErr err = AudioOutputUnitStart(samUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
}

- (void)stopAudioPlayback
{
    AudioSessionSetActive(false);
}





@end
