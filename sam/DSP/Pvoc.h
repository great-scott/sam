//
//  Pvoc.h
//  TRE
//
//  Created by Scott McCoid on 11/15/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#ifndef TRE_Pvoc_h
#define TRE_Pvoc_h

#include "FFTManager.h"
//
//// polar type
//typedef struct t_polar
//{ 
//    float mag; 
//    float phase;
//} POLAR;
//
//// A whole polar window
//typedef struct t_polarWindow
//{
//    POLAR* buffer;
//    POLAR* oldBuffer;
//    int    length;
//    
//} POLAR_WINDOW;
//
//
//typedef struct pvoc_data
//{
//    int     windowSize;
//    float*  buffer[2];
//    
//    int     whichBuffer;
//    float*  window;
//    
//    //queue<polar_window *> windows;
//    //int     data_size;
//    
//    int     io_size;
//    int     count;
//    
//    float*  ola[2];
//    int     index;
//    //queue<SAMPLE *> ready;
//    //float K;
//    
//    POLAR*  space;
//    float*  extraSpace;
//    
//    //uint pool;
//    //CBuffer polar_pool;
//    //CBuffer win_pool;
//} PVOC;
//
//
//
//POLAR_WINDOW* newPolarWindow(int size);
//void freePolarWindow(POLAR_WINDOW* windowToFree);
//
//
////pvc_data * pv_create( uint window_size, uint io_size, uint pool_size );
////void pv_analyze( pvc_data * data, SAMPLE * buffer, uint hop_size );
//void pvUnwrapPhase(POLAR_WINDOW* window);
////void pv_phase_fix( const polar_window * prev, polar_window * curr, float factor );
////void pv_overlap_add( pvc_data * data, polar_window * the_window, uint hop_size );
//
////void pvInverseFFT(FFT* fft, PVOC* pv, const POLAR_WINDOW* window, float* buffer);
//


#endif
