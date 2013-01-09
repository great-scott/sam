//
//  Pvoc.c
//  TRE
//
//  Created by Scott McCoid on 11/15/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#include <stdio.h>
#include "Pvoc.h"
#define PI 3.14159265359

POLAR_WINDOW* newPolarWindow(int size)
{
    POLAR_WINDOW* polarWindow = (POLAR_WINDOW*)malloc(sizeof(POLAR_WINDOW));
    polarWindow->buffer = (POLAR*)malloc(size * sizeof(POLAR));
    polarWindow->oldBuffer = (POLAR*)malloc(size * sizeof(POLAR));
    polarWindow->length = size;
    
    return polarWindow;
}


void freePolarWindow(POLAR_WINDOW* windowToFree)
{
    free(windowToFree->buffer);
    free(windowToFree->oldBuffer);
    windowToFree->buffer = NULL;
    windowToFree->oldBuffer = NULL;
    windowToFree->length = 0;
    
    free(windowToFree);
    windowToFree = NULL;
}


//void pvUnwrapPhase(COMPLEX_SPLIT* window)
//{
//    int length = window->length;
//    POLAR* p = window->buffer;
//    float x;
//    
//    for(int i = 0; i < length; i++ )
//    {
//        x = floor(fabs(p[i].phase / PI ) );
//        if( p[i].phase < 0.0f ) 
//            x *= -1.0f;
//        p[i].phase -= x * PI;
//    }
//}


void pvInverseFFT(FFT* fft, PVOC* pv, const POLAR_WINDOW* window, float* buffer )
{
    COMPLEX_SPLIT* cmp = (COMPLEX_SPLIT *)buffer;
    
    const POLAR* p = (const POLAR *)window->buffer;
    
    for(int i = 0; i < window->length; i++ )
    {
        cmp[i].realp[i] = p[i].mag * cos(p[i].phase);
        cmp[i].imagp[i] = p[i].mag * sin(p[i].phase);
    }
    
    //rfft( (float *)cmp, window->len, FFT_INVERSE );
}


PVOC* pvCreate(int windowSize)
{
    PVOC* pv = (PVOC *)malloc(sizeof(PVOC));
    pv->buffer[0] = (float *)malloc(windowSize * 4 * sizeof(float));
    pv->buffer[1] = (float *)malloc(windowSize * 4 * sizeof(float));
    
    pv->space = (POLAR *)malloc((windowSize / 2) * sizeof(POLAR));
    pv->extraSpace = (float *)malloc(windowSize * sizeof(float));

    pv->windowSize = windowSize;
    
    //data->data_size = 0;
    pv->whichBuffer = 0;
    
    //->io_size = io_size;
    pv->count = 0;
    pv->ola[0] = (float *)malloc(windowSize * 4 * sizeof(float));
    pv->ola[1] = (float *)malloc(windowSize * 4 * sizeof(float));
    pv->index = 0;
    
    memset(pv->ola[0], 0, (windowSize * 4) * sizeof(float));
    memset(pv->ola[1], 0, (windowSize * 4) * sizeof(float));
    
    return pv;
}


//void pvOverlapAdd(PVOC* pv, float* inputWindow, int hopSize)
//{
//    float* window = pv->extraSpace;
//    window = inputWindow;
//    int toOla = pv->windowSize - hopSize;       // to_ola is the number of overlapping samples
//    
//        
//    float* w = pv->ola[pv->index];              // There are 2 ola buffers, this is the first
//    pv->index = !pv->index;                     // switch to the other buffer
//    float* w2 = pv->ola[pv->index];             // assign the other buffer
//    
//    // overlap add
//    float * x = &window[pv->count];             // get a pointer to position indexed by hop_sizes
//    for(int i = 0; i < toOla; i++ )
//        x[i] += window[i];
//
//    // copy
//    memcpy(x+toOla, window+toOla, hopSize * sizeof(float));   
//
//    // queue
//    pv->count += hopSize;
//    while( pv->count >= pv->io_size )
//    {
//        SAMPLE * buffer = NULL;
//        if( data->pool )
//        {
//            if( !data->win_pool.get( &buffer, 1 ) )
//            {
//                fprintf( stderr, "pool exhausted!\n" );
//                assert(FALSE);
//            }
//        }
//        else
//            buffer = new SAMPLE[data->io_size];
//        
//        memcpy( buffer, w, data->io_size * sizeof(SAMPLE) );
//        data->ready.push( buffer );
//        
//        data->count -= data->io_size;
//        w += data->io_size;
//    }
//
//    memset( w2, 0, (data->window_size + data->io_size)*2*sizeof(SAMPLE) );
//    memcpy( w2, w, (data->window_size + data->count) * sizeof(SAMPLE) );
//}



