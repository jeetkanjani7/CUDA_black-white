
OPENCV_LIBPATH=-I/usr/local/lib

OPENCV_INCLUDEPATH=-I/usr/local/include,-I/usr/local/include/opencv 

OPENCV_LIBS=-lopencv_core -lopencv_imgproc -lopencv_highgui

CUDA_INCLUDEPATH=/usr/local/cuda-8.0/include

NVCC_OPTS=-O3 -arch=sm_20 -Xcompiler -Wall -Xcompiler -Wextra -m64

GCC_OPTS=-O3 -Wall -Wextra -m64

Imageop: Imageop.o 
	nvcc -o Imageop Imageop.o -L $(OPENCV_LIBPATH) $(OPENCV_LIBS) $(NVCC_OPTS)

#main.o: main.cpp 
#	g++ -c main.cpp $(GCC_OPTS) -I $(CUDA_INCLUDEPATH) -I $(OPENCV_INCLUDEPATH)

Imageop.o: Imageop.cu
	nvcc -c Imageop.cu $(OPENCV_INCLUDEPATH)


clean:
	rm -f *.o *.png hw
