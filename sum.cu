#include<iostream>

const int n = 4096;
const int m = 2048;

//kernel
__global__ void kernelmatsum(float* A , float*B,float*C, int m,int n)
{
    // int i = blockDim.x*blockIdx.x+threadIdx.x;
    // int j = blockDim.y*blockIdx.y+threadIdx.y;

    // C[blockDim.x*j+i]=A[blockDim.x*j+i]+B[blockDim.x*j+i];

    int r = blockDim.y * blockIdx.y + threadIdx.y;
    int c = blockDim.x * blockIdx.x + threadIdx.x;

    C[r * n + c] = A[r * n + c] + B[r * n + c];
    
}

void metadd(float* A_h,float*B_h,float*C_h,int m,int n){

    float* A_d,*B_d,*C_d;
    int size = m*n*sizeof(float);

    cudaMalloc((void**)&A_d,size);
    cudaMalloc((void**)&B_d,size);
    cudaMalloc((void**)&C_d,size);

    cudaMemcpy(A_d,A_h,size,cudaMemcpyHostToDevice);
    cudaMemcpy(B_d,B_h,size,cudaMemcpyHostToDevice);
    uint threadsX = 32, threadsY = 16, blocksX = ceil(n / threadsX), blocksY = ceil(m / threadsY);
    dim3 blocks(blocksX, blocksY), threads(threadsX, threadsY);
    kernelmatsum<<<blocks,threads>>>(A_d,B_d,C_d,m,n);

    cudaMemcpy(C_h,C_d,size,cudaMemcpyDeviceToHost);

    cudaFree(&A_d);
    cudaFree(&B_d);
    cudaFree(&C_d);



}

int main(){



float * A_h = (float*)malloc(m*n*sizeof(float));
float * B_h = (float*)malloc(m*n*sizeof(float));
float * C_h = (float*)malloc(m*n*sizeof(float));

int sum = 0;
for (int  i = 0; i < m*n; i++)
{
    A_h[i]=sum;
    B_h[i]=sum;
    sum++;
    // std::cout << 2 * sum << std::endl;

}
metadd(A_h,B_h,C_h,m,n);
sum = 0;
for (int  i = 0; i < m*n; i++)
{
    /* code */
    // printf(" %0.0f  ",C_h[i]);
    if(i * 2 != C_h[i]) std::cout << " Error at " << i << std::endl;
    //std::cout<<C_h[i]<<"  ";
}







    

    
    return 0;
}