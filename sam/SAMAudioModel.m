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
#define FILTER_SLOPE_LENGTH 10

@implementation SAMAudioModel

@synthesize windowSize;
@synthesize overlap;
//@synthesize frequencyBuffer;
@synthesize stftBuffer;
@synthesize numFFTFrames;

//----
@synthesize editArea;
@synthesize poly;
@synthesize monitor;
@synthesize mode;
@synthesize touchScale;

double changeTouchYScale(double inputPoint, double scale)
{
    return pow(inputPoint, 2.0) / scale;
}

void shiftToMod(FFT_FRAME* frame)
{
    frame->polarWindowMod->length = frame->windowSize/2;
    int length = frame->polarWindowMod->length;
    
    for (int i = 0; i < length; i++)
    {
        frame->polarWindowMod->buffer[i].mag = frame->polarWindow->buffer[i].mag;
        frame->polarWindowMod->buffer[i].phase = frame->polarWindow->buffer[i].phase;
//        frame->polarWindowMod->oldBuffer[i].mag = frame->polarWindow->oldBuffer[i].mag;
//        frame->polarWindowMod->oldBuffer[i].phase = frame->polarWindow->oldBuffer[i].phase;
    }
}

double interpolate(double x1, double x0, double x, double y1, double y0)
{
    double y = y0 + (y1 - y0) * ((x - x0) / (x1 - x0));
    return y;
}

void filter(POLAR_WINDOW* window, float top, float bottom, int length)
{
    int lowBound = bottom - length; // interpolate from bottom to lower bound (from 0 - 1)
    int highBound = top + length; // interpolate from top to high bound (from 1 - 0)
    
    for (int bin = 0; bin < window->length; bin++)
    {
        if (bin > ceil(top) && bin <= highBound)
        {
            // use interpolator to figure this out
            double interp = interpolate(highBound, top, bin, 1.0, 0.0);
            double newMag = interp * window->buffer[bin].mag;
            window->buffer[bin].mag = newMag;
            
            double newPhase = interp * window->buffer[bin].phase;
            window->buffer[bin].phase = newPhase;
        }
        else if (bin > highBound || bin < lowBound)
        {
            window->buffer[bin].mag = 0.0;
            window->buffer[bin].phase = 0.0;
        }
        else if (bin < floor(bottom) && bin >= lowBound)
        {
            // use interpolator
            double interp = interpolate(lowBound, bottom, bin, 0.0, 1.0);
            double newMag = interp * window->buffer[bin].mag;
            window->buffer[bin].mag = newMag;
            
            double newPhase = interp * window->buffer[bin].phase;
            window->buffer[bin].phase = newPhase;
        }
    }
}


void interpolateBetweenFrames(SAMAudioModel* model, POLAR_WINDOW* current, POLAR_WINDOW* next, POLAR_WINDOW* playback)
{
    float betweenFrameAmt = (float)model->rateCounter / (float)(model->rate * model->overlap);
    double newMag, newPhase;
    
    for (int bin = 0; bin < current->length; bin++)
    {
        newMag = interpolate(0.0, 1.0, betweenFrameAmt, current->buffer[bin].mag, next->buffer[bin].mag);
        playback->buffer[bin].mag = newMag;
        
        newPhase = interpolate(0.0, 1.0, betweenFrameAmt, current->buffer[bin].phase, next->buffer[bin].phase);
        playback->buffer[bin].phase = newPhase;
    }
}

void forwardProcessing(SAMAudioModel* model, int begin, int end)
{
    // Determine the next frame's index
    int nextFrameIndex;
    int frameIndex = model->counter;
    if (model->counter + 1 >= end)
        nextFrameIndex = begin  + 1;
    else
    {
        nextFrameIndex = model->counter + 1;
        if (nextFrameIndex >= end)
            nextFrameIndex = frameIndex;
    }
    
    
    STFT_BUFFER* stft = model->stftBuffer;
    
    // Assign pointers to frames
    FFT_FRAME* frame = stft->buffer[frameIndex];
    FFT_FRAME* nextFrame = stft->buffer[nextFrameIndex];
    FFT_FRAME* playbackFrame = model->fftFrameBuffer[0];
    
    float top, topNext, bottom, bottomNext;
    
    if (model->rateCounter == 0)
    {
        model->top = -1;
        model->topNext = -1;
        model->bottom = 9999;
        model->bottomNext = 9999;
        
        float xCoord = frameIndex * (model->editArea.size.width / stft->size);                   // TODO: make this div static variable
        float xCoordNext = nextFrameIndex * (model->editArea.size.width / stft->size);
        
//        findTopAndBottom(model, xCoord, &model->top, &model->bottom);
//        findTopAndBottom(model, xCoordNext, &model->topNext, &model->bottomNext);
//        
//        top = changeTouchYScale(model->top, model->touchScale);
//        bottom = changeTouchYScale(model->bottom, model->touchScale);
//        
//        topNext = changeTouchYScale(model->topNext, model->touchScale);
//        bottomNext = changeTouchYScale(model->bottomNext, model->touchScale);
        
        // update mod frames
        shiftToMod(frame);
        shiftToMod(nextFrame);
        
        // assign pointers to array of pointers (easier to track down in my head)
        model->polarWindows[0] = frame->polarWindowMod;
        model->polarWindows[1] = nextFrame->polarWindowMod;
        model->polarWindows[2] = playbackFrame->polarWindowMod;
        
        // filter our current and next frame
        filter(model->polarWindows[0], top, bottom, FILTER_SLOPE_LENGTH);            // TODO: won't need to shift and filter 2nd time through
        filter(model->polarWindows[1], topNext, bottomNext, FILTER_SLOPE_LENGTH);
        //-----------
    }
}

void averageAcrossFrames(SAMAudioModel* model, int begin, int end)
{
    STFT_BUFFER* stft = model->stftBuffer;
    int numFrames = end - begin;
    float invNumFrames = 1.0 / numFrames;
    
    int frameIndex;
    float xCoord;
    float newMag, newPhase;
    
    FFT_FRAME* avgFrame = model->fftFrameBuffer[0];
    shiftToMod(avgFrame);
    model->polarWindows[2] = avgFrame->polarWindowMod;
    
    FFT_FRAME* shiftFrame;
    
    for (int i = 0; i < numFrames; i++)
    {
        frameIndex = (begin + i);
        shiftFrame = stft->buffer[frameIndex];
        
        xCoord = frameIndex * (model->editArea.size.width / stft->size);
//        findTopAndBottom(model, xCoord, &model->top, &model->bottom);
//        
//        model->top = changeTouchYScale(model->top, model->touchScale);
//        model->bottom = changeTouchYScale(model->bottom, model->touchScale);
        
        // update mode frames
        shiftToMod(shiftFrame);
        
        //
        model->polarWindows[0] = shiftFrame->polarWindowMod;
        
        // filter
        filter(model->polarWindows[0], model->top, model->bottom, FILTER_SLOPE_LENGTH);
        
        // sum and divide
        for (int j = 0; j < avgFrame->nOver2; j++)
        {
            float currentMag = model->polarWindows[2]->buffer[j].mag;
            float added = (model->polarWindows[0]->buffer[j].mag * invNumFrames);
            newMag = currentMag + added;
            //newPhase = model->polarWindows[2]->buffer[j].phase + (model->polarWindows[0]->buffer[j].phase * invNumFrames);
            model->polarWindows[2]->buffer[j].mag = newMag;
            //model->polarWindows[2]->buffer[j].phase = newPhase;
        }
    
        
        model->top = -1;
        model->bottom = 9999;

    }
}

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
    STFT_BUFFER* stft = this->stftBuffer;
    
    // Wait till file loaded
    if (this->fileLoaded == YES)
    {
        // time to process
        if (this->dspTick == 0)
        {
            // This section only needs to happen every time counter increases
            // Get beginning and endpoints
            int begin = floor(stft->size / this->editArea.size.width * this->poly.boundPoints.x);
            int end = ceil(stft->size / this->editArea.size.width * this->poly.boundPoints.y);
            
            FFT_FRAME* playbackFrame = this->fftFrameBuffer[0];
            
            switch (this->mode)
            {
                case FORWARD:
                    forwardProcessing(this, begin, end);
                    interpolateBetweenFrames(this, this->polarWindows[0], this->polarWindows[1], this->polarWindows[2]);
                    break;
                    
                case AVERAGE:
                    averageAcrossFrames(this, begin, end);
                    break;
                    
                default:
                    break;
            }
            
            // this is every rateCounter tick
            pvUnwrapPhase(this->polarWindows[2]);
            
            if (this->pastWindow != nil)
                pvFixPhase(this->pastWindow, this->polarWindows[2], 0.25);
            
            //------------------- don't change this
            inverseFFT(this->fftManager, playbackFrame, this->circleBuffer[0]);
            
            // assign remaining values to playback buffer
            // shift and overlap add new buffer
            int diff = this->windowSize - this->hopSize;
            for (int i = 0; i < diff; i++)
                this->circleBuffer[1][i] = (this->circleBuffer[1][this->hopSize + i] + this->circleBuffer[0][i]) * 0.5;
            
            for (int i = 0; i < this->hopSize; i++)
                this->circleBuffer[1][diff + i] = this->circleBuffer[0][diff + i];
            //--------------------------------------------------------------------
            
            this->pastWindow = this->polarWindows[2];
            
            // progress time
            if (this->mode == FORWARD)
            {
                this->rateCounter++;
            }
            
            if (this->rateCounter % (this->rate * this->overlap) == 0)
            {
                this->counter++;
                this->rateCounter = 0;
            }
            
            if (this->counter >= end || this->counter < begin)          // TODO: this needs to act more like, matt wright's buffer shuffler thingy
                this->counter = begin + 1;

        }
        
        for (int frameCounter = 0; frameCounter < inNumberFrames; frameCounter++)
        {
            buffer[frameCounter] = this->circleBuffer[1][frameCounter + this->dspTick];
        }
        
        
        // Deal with progressing time / dsp ticks
        this->dspTick += inNumberFrames;
        
        if (this->dspTick >= this->hopSize)
            this->dspTick = 0;
        
    }
    else    // set the output to 0.0
    {
        memset(buffer, 0.0, inNumberFrames);
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
        windowSize = 2048;
        halfWindowSize = windowSize / 2;
        overlap = 2;
        hopSize = windowSize / overlap;
        audioBuffer = nil;        
        normalizationFactor = 0.0;
        counter = 0;
        rate = 4;
        rateCounter = 0;
        
        // Appwide AU settings
        blockSize = 1024;
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
        circleBuffer[2] = (float *)malloc(windowSize * sizeof(float));
        circleBuffer[3] = (float *)malloc(windowSize * sizeof(float));
        
        lpIn = (float *)malloc(halfWindowSize * sizeof(float));
        lpOut = (float *)malloc(halfWindowSize * sizeof(float));
        memset(lpIn, 0.0, halfWindowSize * sizeof(float));
        memset(lpOut, 0.0, halfWindowSize * sizeof(float));
        
        // Polar window buffers        
        polarWindows[0] = nil;      // in general, this is previous
        polarWindows[1] = nil;      // this is current frame
        polarWindows[2] = nil;      // this is interpolated -> actual playback frame
        currentPolar = 0;
        
        //-----------------------------------------------
        fileLoaded = NO;
        shapeReferences = nil;
        touchScale = [self findTouchScale];
        
        fftFrameBuffer[0] = newFFTFrame(windowSize);
        fftFrameBuffer[1] = newFFTFrame(windowSize);
        
        whichFrame = 1;
        hopPosition = 0;
        monitor = NO;
        
        top = -1;
        bottom = 9999;
        topNext = -1;
        bottomNext = 9999;
        
//        top = 50;
//        bottom = 0;
//        topNext = 70;
//        bottomNext = 0;
        
        pastWindow = nil;
        
        mode = FORWARD;
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
    
    free(lpIn);
    free(lpOut);
    free(audioBuffer);
    free(circleBuffer[0]);
    free(circleBuffer[1]);
    free(circleBuffer[2]);
    free(circleBuffer[3]);
    
    // Free stft buffer
    freeSTFTBuffer(stftBuffer);
    
    // Free fft frames
    freeFFTFrame(fftFrameBuffer[0]);
    freeFFTFrame(fftFrameBuffer[1]);
    
    // Free fft stuff and instance
    freeFFT(fftManager);
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


#pragma mark - Utility Methods -
// This method creates a mono track and stuffs it into the left channel
- (void)convertToMonoWith:(float *)left andRightChannel:(float *)right withSize:(int)size
{
    for (int i = 0; i < size; i++)
        left[i] = (left[i] + right[i]) / 2.0;
}

// Converts from AudioUnit sample type to float
- (void)convert:(AudioUnitSampleType *)input to:(float *)output withSize:(int)size
{
    for (int i = 0; i < size; i++)
    {
        output[i] = (float)((SInt16)(input[i] >> 9) / 32768.0);
    };
}

- (float)findTouchScale
{
    float scale = pow(editArea.size.height, 2) / (windowSize / 2);
    return scale;
}

- (void)createBuffers
{
    if (audioBuffer != nil)
        free(audioBuffer);
    
    audioBuffer = (float *)malloc(numFramesInAudioFile * sizeof(float));
    
    if (stftBuffer != nil)
        free(stftBuffer);
    
    stftBuffer = newSTFTBuffer(windowSize, overlap, &numFFTFrames, numFramesInAudioFile);
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
    float* leftFloatBuffer = calloc(numFramesInAudioFile, sizeof(float));
    float* rightFloatBuffer = calloc(numFramesInAudioFile, sizeof(float));
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
    [self convert:leftBuffer to:leftFloatBuffer withSize:numFramesInAudioFile];
    
    // If stereo convert right channel to float then convert to mono
    if (channelCount == 2)
    {
        [self convert:rightBuffer to:rightFloatBuffer withSize:totalFramesInFile];
        [self convertToMonoWith:(float *)leftFloatBuffer andRightChannel:(float *)rightFloatBuffer withSize:numFramesInAudioFile];
    }
    
    // Copy over samples from leftbuffer to main audio buffer
    memcpy(audioBuffer, leftFloatBuffer, numFramesInAudioFile * sizeof(float));
    
    free(leftBuffer);
    free(leftFloatBuffer);
    if (rightBuffer != NULL)
    {
        free(rightBuffer);
        free(rightFloatBuffer);
    }
    
    // Finally set the file loaded flag
    fileLoaded = YES;
}


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
    AudioOutputUnitStop(samUnit);
}

- (void)setEditArea:(CGRect)newEditArea
{
    editArea = newEditArea;
    touchScale = [self findTouchScale];
}

- (CGRect)editArea
{
    return editArea;
}



@end
