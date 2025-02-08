#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void sinArray(float *a, float *b, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n)
        b[i] = sinf(a[i]);
}

int main(void)
{
    int n;

    printf("Enter n: ");
    scanf("%d", &n);

    float *a = (float *)malloc(n * sizeof(float));
    float *b = (float *)malloc(n * sizeof(float));

    printf("Enter elements for array:\n");
    for (int i = 0; i < n; i++)
        scanf("%f", &a[i]);

    float *d_a, *d_b;

    int s = sizeof(float) * n;

    cudaMalloc((void **)&d_a, s);
    cudaMalloc((void **)&d_b, s);

    cudaMemcpy(d_a, a, s, cudaMemcpyHostToDevice);

    sinArray<<<1, n>>>(d_a, d_b, n);
    cudaMemcpy(b, d_b, s, cudaMemcpyDeviceToHost);

    printf("Sin Array: \n");
    for (int i = 0; i < n; i++)
        printf("%f ", b[i]);
    printf("\n");

    cudaFree(d_a);
    cudaFree(d_b);

    return 0;
}
