//CUDA Cのためのinclude(gpu側)
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

//C include(cpu側のみ)
#include <stdio.h>
#include <stdlib.h>

//CUDA How-to memo
//スレッドの固有の番号を取得:blockIdx.x * blockDim.x + threadIdx.x
//メモリの内容をコピー:cudaMemcpy(HostMemory, Device_array, num_of_rnd * 4, cudaMemcpyDeviceToHost);
//CUDAの処理完了を待機:cudaDeviceSynchronize();
//デバイスメモリ確保:int* Device_addr; cudaMalloc((void**)&Device_addr, サイズ);
//デバイスメモリ解放;cudaFree(ポインタ)
//メモリコピー:cudaMemcpy(HostMemory(dst), Device_array(src), num_of_rnd * 4, cudaMemcpyDeviceToHost);


__device__ double Leibniz_One(unsigned long count) {
    count++;
    return 8.0 / (16.0 * count * (count - 1.0) + 3.0);
}

__global__ void Leibniz_to_Array(double *dst, unsigned int head) {
    dst[blockIdx.x * blockDim.x + threadIdx.x + head] = Leibniz_One(blockIdx.x * blockDim.x + threadIdx.x + head);
}

double Host_Leibniz(int start, int size,int Acc, double* Host_Leibniz_Array) {
    printf("starting %d\n", start);
    //ライプニッツの式を計算する際の各項を保存するためのメモリ確保
    //GPUデバイス側
    double* Device_Leibniz;
    cudaMalloc((void**)&Device_Leibniz, Acc * 8);
    
    //ライップニッツの式を計算
    Leibniz_to_Array << <16, Acc / 16 >> > (Device_Leibniz, start);
    cudaDeviceSynchronize();

    //GPUメモリから計算結果を転送
    cudaMemcpy(Host_Leibniz_Array, Device_Leibniz, Acc * 8, cudaMemcpyDeviceToHost);

    //cpuで足し算して出力
    double result = 0.0;
    for (int i = 0; i < Acc; i++) {
        result += Host_Leibniz_Array[i];
    }
    return  result;
 }

int main() {
    //ライプニッツの式を計算する際のGPUで一度に計算させる項数
    unsigned const int Acc=4096*4;
    //ライプニッツの式をGPUに計算させる回数
    unsigned const int count = 8;
    //ホスト側メモリ確保
    //中身はheapに確保する(stack overflow対策)
    double* Host_Leibniz_Array[count];
    //countの回数だけ処理を実行
    double re = 0;
    for (int i = 0; i < count; i++) {
        Host_Leibniz_Array[i] = new double[Acc];//heapに確保
        re += Host_Leibniz(i*Acc, Acc, Acc, Host_Leibniz_Array[i]);
    }
    printf("%1.10lf\n", re);
}