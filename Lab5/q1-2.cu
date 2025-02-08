#include <stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void add(int *a, int *b, int *c, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n)
        c[i] = a[i] + b[i];
}

int main(void)
{
    int n;

    printf("Enter n: ");
    scanf("%d", &n);

    int a[n], b[n], c[n];

    printf("Enter elements for 1st array:\n");
    for (int i = 0; i < n; i++)
        scanf("%d", &a[i]);

    printf("Enter elements for 2nd array:\n");
    for (int i = 0; i < n; i++)
        scanf("%d", &b[i]);

    int *d_a, *d_b, *d_c;

    int s = sizeof(int) * n;

    cudaMalloc((void **)&d_a, s);
    cudaMalloc((void **)&d_b, s);
    cudaMalloc((void **)&d_c, s);

    cudaMemcpy(d_a, a, s, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, s, cudaMemcpyHostToDevice);

    add<<<1, n>>>(d_a, d_b, d_c, n);
    cudaMemcpy(c, d_c, s, cudaMemcpyDeviceToHost);

    printf("Vector (1,n): \n");
    for (int i = 0; i < n; i++)
        printf("%d ", c[i]);
    printf("\n");

    add<<<n, 1>>>(d_a, d_b, d_c, n);
    cudaMemcpy(c, d_c, s, cudaMemcpyDeviceToHost);

    printf("Vector (n,1): \n");
    for (int i = 0; i < n; i++)
        printf("%d ", c[i]);
    printf("\n");

    dim3 dimGrid((int)ceil(n / 256.0), 1, 1); 
    dim3 dimBlock(256, 1, 1); 

    add<<<dimGrid, dimBlock>>>(d_a, d_b, d_c, n);
    cudaMemcpy(c, d_c, s, cudaMemcpyDeviceToHost);

    printf("Vector (%d, 256): \n", dimGrid.x);
    for (int i = 0; i < n; i++)
        printf("%d ", c[i]);
    printf("\n");

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}