//
//  SAMAudioModel.m
//  SAM
//
//  Created by Scott McCoid on 10/22/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "SAMAudioModel.h"
#import "SAMLinkedList.h"

#define PI 3.14159265359
#define TWO_PI (2 * PI)
#define FILTER_SLOPE_LENGTH 6

@implementation SAMAudioModel

@synthesize windowSize;
@synthesize overlap;
@synthesize stftBufferSize;
@synthesize stftBuffer;
@synthesize numFFTFrames;

//----
@synthesize editArea;
@synthesize poly;
@synthesize monitor;
@synthesize mode;
@synthesize touchScale;
@synthesize numberOfVoices;
@synthesize isRecording;


void shiftToMod(FFT_FRAME* frame)
{
    frame->polarWindowMod->length = frame->windowSize/2;
    int length = frame->polarWindow->length;
    
    for (int i = 0; i < length; i++)
    {
        frame->polarWindowMod->buffer[i].mag = frame->polarWindow->buffer[i].mag;
        frame->polarWindowMod->buffer[i].phase = frame->polarWindow->buffer[i].phase;
        
        frame->polarWindowMod->oldBuffer[i].mag = frame->polarWindow->oldBuffer[i].mag;
        frame->polarWindowMod->oldBuffer[i].phase = frame->polarWindow->oldBuffer[i].phase;
    }
}

double interpolate(double x1, double x0, double x, double y1, double y0)
{
    double y = y0 + (y1 - y0) * ((x - x0) / (x1 - x0));
    return y;
}

float lowPassFilterScale(int index, int divisor)
{
    return cos(PI * index / (divisor * 2));
}

float highPassFilterScale(int index, int divisor)
{
    return sin(PI * index / (divisor * 2));
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
            //double interp = interpolate(highBound, top, bin, 1.0, 0.0);
            
            double interp = lowPassFilterScale(bin - top, FILTER_SLOPE_LENGTH);
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
            double interp = highPassFilterScale(bin - (bottom - FILTER_SLOPE_LENGTH), FILTER_SLOPE_LENGTH); //interpolate(lowBound, bottom, bin, 0.0, 1.0);
            double newMag = interp * window->buffer[bin].mag;
            window->buffer[bin].mag = newMag;
            
            double newPhase = interp * window->buffer[bin].phase;
            window->buffer[bin].phase = newPhase;
        }
    }
}


void interpolateBetweenFrames(SAMAudioModel* model, POLAR_WINDOW* current, POLAR_WINDOW* next, POLAR_WINDOW* playback, int voice)
{
    // betweenFrameAmt corresponds with rateCounter
    float betweenFrameAmt = (float)model->shapeReferences[voice].ratePosition / (float)(model->shapeReferences[voice].rate * model->overlap);
    double newMag, newPhase;
    
    float currentMag, nextMag;
    float currentPhi, nextPhi;
    
    for (int bin = 0; bin < model->halfWindowSize; bin++)
    {
        currentMag = current->buffer[bin].mag;
        nextMag = next->buffer[bin].mag;
        
        newMag = interpolate(0.0, 1.0, betweenFrameAmt, current->buffer[bin].mag, next->buffer[bin].mag);
        playback->buffer[bin].mag = newMag;
        
        //playback->buffer[bin].mag = current->buffer[bin].mag;
        
        currentPhi = current->buffer[bin].phase;
        nextPhi = next->buffer[bin].phase;
        
        newPhase = interpolate(0.0, 1.0, betweenFrameAmt, current->buffer[bin].phase, next->buffer[bin].phase);
        playback->buffer[bin].phase = newPhase;
        
        //playback->buffer[bin].phase = current->buffer[bin].phase;
    }
}

void filterMode(SAMAudioModel* model, int voiceIndex)
{
    float top, topNext, bottom, bottomNext;
    int frameIndex, nextFrameIndex;
    
    SAMLinkedList* list = model->shapeReferences[voiceIndex].pointList;
    
    if (list.length > 0 && list.current != nil)
    {
        // crazy memory align error, explained here: http://www.galloway.me.uk/2010/10/arm-hacking-exc_arm_da_align-exception/
        memcpy(&frameIndex, &list.current->data->x, sizeof(frameIndex));
        //frameIndex = list.current->data->x;
        top = list.current->data->top;
        bottom = list.current->data->bottom;
    
        if (list.current->nextNode == nil)
        {
            nextFrameIndex = list.tail->data->x;
            topNext = list.tail->data->top;
            bottomNext = list.tail->data->bottom;
        }
        else
        {
            nextFrameIndex = list.current->nextNode->data->x;
            topNext = list.current->nextNode->data->top;
            bottomNext = list.current->nextNode->data->bottom;
        }
    
        STFT_BUFFER* stft = model->stftBuffer;
    
        // assign pointers to frames
        FFT_FRAME* frame = stft->buffer[frameIndex];
        FFT_FRAME* nextFrame = stft->buffer[nextFrameIndex];
        FFT_FRAME* playbackFrame = model->fftFrameBuffer[0];
    
        if (model->shapeReferences[voiceIndex].ratePosition == 0)
        {
            // TODO: think about this step more
            shiftToMod(frame);
            shiftToMod(nextFrame);
        
            model->polarWindows[0] = frame->polarWindowMod;
            model->polarWindows[1] = nextFrame->polarWindowMod;
            model->polarWindows[2] = playbackFrame->polarWindowMod;
        
            filter(model->polarWindows[0], top, bottom, FILTER_SLOPE_LENGTH);
            filter(model->polarWindows[1], topNext, bottomNext, FILTER_SLOPE_LENGTH);
     
            switch (model->shapeReferences[voiceIndex].playMode)
            {
                case FORWARD:
                    moveListForward(list);
                    break;
                    
                case REVERSE:
                    moveListBackward(list);
                    break;
                    
                case UPDOWN:
                    moveListForwardReverse(list);
                    break;
                    
                case RANDOM:
                    moveListRandom(list);
                    break;
                    
                default:
                    break;
            }
        }

        interpolateBetweenFrames(model, model->polarWindows[0], model->polarWindows[1], model->polarWindows[2], voiceIndex);
    }
    
}


float summingBus(SAMAudioModel* model, int index)
{
    float scale = 1.0 / (float)model->numberOfVoices;
    float output = 0.0;
    
    for (int i = 0; i < MAX_VOICES; i++)
    {
        if (model->voiceReferences[i] != nil)   // TODO: fix all of these checks, shouldn't have to do this here
            output = output + (model->voiceReferences[i]->output[index] * scale);
    }
    
    return output;
}

void averageAcrossFrames(SAMAudioModel* model, int voiceIndex)
{
//    STFT_BUFFER* stft = model->stftBuffer;
//    int numFrames = end - begin;
//    float invNumFrames = 1.0 / numFrames;
//    
//    int frameIndex;
//    float xCoord;
//    float newMag, newPhase;
//    
//    FFT_FRAME* avgFrame = model->fftFrameBuffer[0];
//    shiftToMod(avgFrame);
//    model->polarWindows[2] = avgFrame->polarWindowMod;
//    
//    FFT_FRAME* shiftFrame;
//    
//    for (int i = 0; i < numFrames; i++)
//    {
//        frameIndex = (begin + i);
//        shiftFrame = stft->buffer[frameIndex];
//        
//        xCoord = frameIndex * (model->editArea.size.width / stft->size);
////        findTopAndBottom(model, xCoord, &model->top, &model->bottom);
////        
////        model->top = changeTouchYScale(model->top, model->touchScale);
////        model->bottom = changeTouchYScale(model->bottom, model->touchScale);
//        
//        // update mode frames
//        shiftToMod(shiftFrame);
//        
//        //
//        model->polarWindows[0] = shiftFrame->polarWindowMod;
//        
//        // filter
//        filter(model->polarWindows[0], model->top, model->bottom, FILTER_SLOPE_LENGTH);
//        
//        // sum and divide
//        for (int j = 0; j < avgFrame->nOver2; j++)
//        {
//            float currentMag = model->polarWindows[2]->buffer[j].mag;
//            float added = (model->polarWindows[0]->buffer[j].mag * invNumFrames);
//            newMag = currentMag + added;
//            //newPhase = model->polarWindows[2]->buffer[j].phase + (model->polarWindows[0]->buffer[j].phase * invNumFrames);
//            model->polarWindows[2]->buffer[j].mag = newMag;
//            //model->polarWindows[2]->buffer[j].phase = newPhase;
//        }
//
//    }
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
    
    // Wait till file loaded
    if (this->fileLoaded == YES && this->numberOfVoices > 0)
    {
        this->inProcessingLoop = YES;
        SAMLinkedList* list;
        for (int l = 0; l < MAX_VOICES; l++)
        {
            list = this->shapeReferences[l].pointList;
            if (list != nil)
                break;
        }
        if (list.length > 0)
        {
        // time to process
        if (this->dspTick == 0)
        {
            // zero out buffer
            memset(this->circleBuffer[2], 0.0, this->windowSize);
            
            //for (int voice = 0; voice < this->numberOfVoices; voice++)      //TODO: I don't like this, but I'm doing it anyways
            for (int voice = 0; voice < MAX_VOICES; voice++)
            {
                if (this->voiceReferences[voice] != nil)
                {
                    FFT_FRAME* playbackFrame = this->fftFrameBuffer[0];
            
                    switch (this->mode)
                    {
                        case FORWARD_MODE:
                            filterMode(this, voice);
                            break;
                    
                        case AVERAGE_MODE:
                            //averageAcrossFrames(this, begin, end);
                            break;
                    
                        default:
                            break;
                    }
            
                    // this is every rateCounter tick
                    pvUnwrapPhase(this->polarWindows[2]);
            
                    if (this->pastWindow != nil)
                        pvFixPhase(this->pastWindow, this->polarWindows[2], 0.25);
            
                    //------------------- inverse and overlap + add                
                    inverseFFT(this->fftManager, playbackFrame, this->voiceReferences[voice]->transform);
                    
                    vDSP_vmul(this->voiceReferences[voice]->transform, 1, this->fftManager->invWindow, 1, this->voiceReferences[voice]->transform, 1, this->fftManager->fftLength);
                
                    int diff = this->windowSize - this->hopSize;
                    for (int i = 0; i < diff; i++)
                        this->voiceReferences[voice]->output[i] = (this->voiceReferences[voice]->output[this->hopSize + i] + this->voiceReferences[voice]->transform[i]);
                
                    for (int i = 0; i < this->hopSize; i++)
                        this->voiceReferences[voice]->output[diff + i] = this->voiceReferences[voice]->transform[diff + i];
            
                    this->pastWindow = this->polarWindows[0];                   // consider putting this in VOICE
                
            
                    // progress time
                    this->shapeReferences[voice].ratePosition++;
            
//                  if (this->rateCounter % (this->rate * this->overlap) == 0)
                    if (this->shapeReferences[voice].ratePosition % this->shapeReferences[voice].rate == 0)
                    {
                        this->shapeReferences[voice].ratePosition = 0;
                    }
                }
            }
        }
        
        for (int frameCounter = 0; frameCounter < inNumberFrames; frameCounter++)
        {
            buffer[frameCounter] = summingBus(this, frameCounter + this->dspTick);
        }
        
        // Deal with progressing time / dsp ticks
        this->dspTick += inNumberFrames;
        if (this->dspTick >= this->hopSize)
            this->dspTick = 0;
        }
        
        this->inProcessingLoop = NO;
    }
    else    // set the output to 0.0
    {
        //memset(buffer, 0.0, inNumberFrames);
        for (int i = 0; i < inNumberFrames; i++)
            buffer[i] = 0.0;
    }
    
    if (this->isRecording)
        ExtAudioFileWriteAsync(this->recordingAudioFileRef, inNumberFrames, ioData);
    
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
        rate = 1;
        rateCounter = 0;
        
        // Appwide AU settings
        blockSize = 1024;
        sampleRate = 44100;
        
        // DSP Tick Business
        numberOfDSPTicks = hopSize / blockSize;          // This better be an integer...
        dspTick = 0;                                        // Always start off on 0
        modAmount = 0;//numberOfDSPTicks / overlap;
        
        // Allocate memory and initialize fft manager
        fftManager = newFFT(windowSize, true);
        NSAssert(fftManager != NULL, @"Error creating fft manager.");
        
        stftBuffer = nil;
        
        // Setup an audio session
        [self setupAudioSession];
        
        // Setup/initialize an audio unit
        //[self setupAudioUnit];
        
        // Setup/initialize AUGraph
        [self setupAudioProcessingGraph];
        
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
        touchScale = [self findTouchScale];
        
        fftFrameBuffer[0] = newFFTFrame(windowSize);
        fftFrameBuffer[1] = newFFTFrame(windowSize);
        
        whichFrame = 1;
        hopPosition = 0;
        monitor = NO;
        
        pastWindow = nil;
        
        mode = FORWARD_MODE;
        numberOfVoices = 0;
        
        // make sure all these shape references are nil
        for (int i = 0; i < MAX_VOICES; i++)
            shapeReferences[i] = nil;
        
        stftBufferSize = 0;
        isRecording = NO;
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
    
    // Free voices
    for (int i = 0; i < MAX_VOICES; i++)
    {
        if (voiceReferences[i] != nil)
            freeVoice(voiceReferences[i]);
    }
}


#pragma mark - Audio Unit Init -

- (void)setupAudioProcessingGraph
{
    NSLog (@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;
    
    result = NewAUGraph(&processingGraph);
    NSAssert1(result == noErr, @"AUGraph Init Error: %ld", result);
    
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    // Multichannel mixer unit
    AudioComponentDescription GeneratorUnitDescription;
    GeneratorUnitDescription.componentType          = kAudioUnitType_Mixer;
    GeneratorUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    GeneratorUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    GeneratorUnitDescription.componentFlags         = 0;
    GeneratorUnitDescription.componentFlagsMask     = 0;
    
    // Add nodes to the audio processing graph.
    NSLog (@"Adding nodes to audio processing graph");
    
    AUNode   iONode;       // node for I/O unit
    AUNode   genNode;      // node for Generator
    
    // Add the nodes to the audio processing graph
    result =    AUGraphAddNode (processingGraph, &iOUnitDescription, &iONode);
    NSAssert1(result == noErr, @"AUGraphNewNode failed for I/O unit: %ld", result);
    
    
    result =    AUGraphAddNode (processingGraph, &GeneratorUnitDescription, &genNode);
    NSAssert1(result == noErr, @"AUGraphNewNode failed for Mixer: %ld", result);
    
    //............................................................................
    // Open the audio processing graph
    
    // Following this call, the audio units are instantiated but not initialized
    //    (no resource allocation occurs and the audio units are not in a state to
    //    process audio).
    result = AUGraphOpen (processingGraph);
    NSAssert1(result == noErr, @"AUGraph open failed: %ld", result);

    // Get references to each node
    result = AUGraphNodeInfo (processingGraph, genNode, NULL, &samUnit);
    NSAssert1(result == noErr, @"AUGraph get node info failed: %ld", result);
    
//    result = AUGraphNodeInfo(processingGraph, iONode, NULL, &iOUnit);
//    NSAssert1(result == noErr, @"AUgraph get node info failed: %ld", result);
    
    
    // Setting up samUnit as a multichannel mixer with one input so we can register that callback
    UInt32 busCount = 1;
    result = AudioUnitSetProperty(samUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &busCount, sizeof(busCount));
    NSAssert1(result == noErr, @"Error setting bus count to 1: %ld", result);
    
    UInt32 maximumFramesPerSlice = 4096;
    result = AudioUnitSetProperty(samUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximumFramesPerSlice, sizeof(maximumFramesPerSlice));
    NSAssert1(result == noErr, @"SAM AU Max Frames Per Slice Error: %ld", result);
    
    // attach OUR callback to this
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    //result = AudioUnitSetProperty(samUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(callbackStruct));
    
    result = AUGraphSetNodeInputCallback(processingGraph, genNode, 0, &callbackStruct);
    NSAssert1(result == noErr, @"Error setting callback: %ld", result);
    
    
    // Set stream format stuff
    // set format to 32 bit, single channel, floating point, linear PCM
    const int fourBytesPerFloat = 4;
    const int eightBitsPerByte = 8;
    
    AudioStreamBasicDescription streamFormat = {0};
    streamFormat.mSampleRate =       44100;
    streamFormat.mFormatID =         kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =      kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket =   fourBytesPerFloat;
    streamFormat.mFramesPerPacket =  1;
    streamFormat.mBytesPerFrame =    fourBytesPerFloat;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel =   fourBytesPerFloat * eightBitsPerByte;
    
//    result = AudioUnitSetProperty(iOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat));
//    NSAssert1(result == noErr, @"Error setting IO stream format: %ld", result);
    
    result = AudioUnitSetProperty(samUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat));
    NSAssert1(result == noErr, @"Error setting Generator stream format: %ld", result);
    

    // Try setting sample rate for mixer
    Float64 graphSampleRate = sampleRate;
    result = AudioUnitSetProperty(samUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &graphSampleRate, sizeof(graphSampleRate));
    NSAssert1(result == noErr, @"Error setting SAM sample rate: %ld", result);
    
    
    result = AUGraphConnectNodeInput(processingGraph, genNode, 0, iONode, 0);
    NSAssert1(result == noErr, @"Error connecting AUGraph nodes: %ld", result);
    
    
    // Diagnostic code
    // Call CAShow if you want to look at the state of the audio processing
    //    graph.
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);
    
    NSLog (@"Initializing the audio processing graph");
    // Initialize the audio processing graph, configure audio data stream formats for
    //    each input and output, and validate the connections between audio units.
    // Initialize the graph
    result = AUGraphInitialize(processingGraph);
    NSAssert1(result == noErr, @"Error initializing AUGraph: %ld", result);
    
}

- (void)setupAudioSession
{
    OSStatus status;
    Float32 bufferDuration = (blockSize + 0.5) / sampleRate;
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


#pragma mark - Private Methods - 

-(void)startRecording

{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    documentsDirectory = [paths objectAtIndex:0];
    
    NSString *destinationFilePath = [[NSString alloc] initWithFormat: @"%@/testrecording.wav", documentsDirectory];
    
    fileUrl = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    
    OSStatus status;
    
    // prepare a 16-bit int file format, sample channel count and sample rate
    AudioStreamBasicDescription dstFormat;
    dstFormat.mSampleRate=44100.0;
    dstFormat.mFormatID=kAudioFormatLinearPCM;
    dstFormat.mFormatFlags=kAudioFormatFlagsNativeEndian|kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
    dstFormat.mBytesPerPacket=4;
    dstFormat.mBytesPerFrame=4;
    dstFormat.mFramesPerPacket=1;
    dstFormat.mChannelsPerFrame=1;      // mono right?
    dstFormat.mBitsPerChannel=16;
    dstFormat.mReserved=0;
    
    // create the capture file
    status = ExtAudioFileCreateWithURL(fileUrl, kAudioFileWAVEType, &dstFormat, NULL, kAudioFileFlags_EraseFile, &recordingAudioFileRef);
    
    
    NSAssert1(status == noErr, @"Error starting unit: %ld", status);
    
    
    // set the capture file's client format to be the canonical format from the queue
    status = ExtAudioFileSetProperty(recordingAudioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &dstFormat);
    
    NSAssert1(status == noErr, @"couldnt set input format: %ld", status);
    
    ExtAudioFileSeek(recordingAudioFileRef, 0);
    
    isRecording = YES;
    
}

- (void)stopRecording
{
    ExtAudioFileDispose(recordingAudioFileRef);
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
    
    NSLog(@"File Loaded");
}


- (BOOL)calculateSTFT
{
    //computeSTFT(fftManager, stftBuffer, audioBuffer);
    computeSTFT_zeroPad(fftManager, stftBuffer, audioBuffer, numFramesInAudioFile);
    stftBufferSize = stftBuffer->size;
    
    NSNumber *size = [NSNumber numberWithFloat:stftBufferSize];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: size, @"size", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setStftSize"
                                                        object:self
                                                      userInfo:dict];
    
    // returns YES when finished
    NSLog(@"STFT Calculated");
    return YES;
}

- (void)addShape:(RegionPolygon *)shapeReference
{
    // where does number of voices get set?
    if (numberOfVoices < MAX_VOICES)
    {
        // find open space for voice
        int index = 0;
        while (shapeReferences[index] != nil && index < MAX_VOICES)
            index++;
        
        // store reference to shape object
        shapeReferences[index] = shapeReference;
        
        // create voice
        VOICE* voice = newVoice(index, windowSize);
        voiceReferences[index] = voice;
    }
}

- (void)removeShape:(RegionPolygon *)shapeReference
{
    // remove shape
    for (int i = 0; i < MAX_VOICES; i++)
    {
        if (shapeReferences[i] == shapeReference)
        {
            // spin here until we're done with current dsp process
            while (inProcessingLoop == YES);
            
            // get reference to voice and free it
            VOICE* voice = voiceReferences[i];
            freeVoice(voice);
            
            // nil out shape and voice array stuff
            shapeReferences[i] = nil;
            voiceReferences[i] = nil;
            
            // decrease number of voices
            numberOfVoices--;
        }
    }
    
}

- (void)startAudioPlayback
{
    AudioSessionSetActive(true);
    
    // Start playback
//    OSErr err = AudioOutputUnitStart(samUnit);
//    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    
    AUGraphStart(processingGraph);
}

- (void)stopAudioPlayback
{
    AudioSessionSetActive(false);
    //AudioOutputUnitStop(samUnit);
    
    AUGraphStop(processingGraph);
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
