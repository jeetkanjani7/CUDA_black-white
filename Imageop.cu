#include <stdio.h>
#include <cuda_runtime.h>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "opencv2/imgproc/imgproc.hpp"

using namespace std;
using namespace cv;
	
__global__ void rgba_to_greyscale(uchar3 *rgbaImage, unsigned char* d_grayscale, int numRows, int numCols)
{
	
    //printf("%u",rgbaImage[threadIdx.x]);
    int absolute_position_x = (blockIdx.x * blockDim.x) + threadIdx.x;
    int absolute_position_y = (blockIdx.y * blockDim.y) + threadIdx.y;
    int Id = absolute_position_x + absolute_position_y*numCols;
    

    if ( absolute_position_x >= numCols ||  absolute_position_y >= numRows )
    { 
     return;
    }

    uchar3 rgba = rgbaImage[Id];

    float channelSum = 0.299f * rgba.x + 0.587f * rgba.y + 0.114f * rgba.z;
    
    d_grayscale[Id] = channelSum;
  
}

int main()
{

    Mat input,input_gray;   
    input = imread("/home/jeetkanjani7/scene.jpg",-1); 
    cout<<"total: "<<input.total();
    
    uchar3 *d_inputImage = new uchar3[input.total()];
    
    unsigned char *d_grayscale;
    unsigned char *h_grayscale = (unsigned char*)malloc(input.total());

    cudaMalloc((void**)&d_grayscale,input.total());
  

   cudaMalloc((void**)&d_inputImage,input.total()*sizeof(uchar3));
    cudaMemcpy(d_inputImage, input.data,input.total()*sizeof(uchar3), cudaMemcpyHostToDevice);
    
    int numrows = input.rows;
    int numcols = input.cols; 
    
    const dim3 blockSize(16, 16, 1);  //TODO
    const dim3 gridSize((numcols/blockSize.x),(numrows/blockSize.y),1);  //TODO
    
    cout<<"\ngridSize::"<<gridSize.x<<" "<<gridSize.y;
    cout<<"\nBlockSize::"<<blockSize.x<<" "<<blockSize.y<<endl;

   
    
    rgba_to_greyscale<<<gridSize, blockSize>>>(d_inputImage, d_grayscale, numrows, numcols);
    cudaThreadSynchronize();
    
   cudaMemcpy(h_grayscale, d_grayscale,input.total(), cudaMemcpyDeviceToHost);
     cout<<static_cast<int>(h_grayscale[7])<<endl;
    Mat img(numrows,numcols,CV_8UC1,h_grayscale,cv::Mat::AUTO_STEP);
    imshow("rgb",img); 
    cout<<"image dims: "<<img.size();
    cudaDeviceSynchronize();
    
    printf("That's all!\n");
    waitKey(0);
     
    return 0;

}