#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void conv(int *N, int width, int *M, int mask_width, int *P)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int sum = 0;
    if (i >= (mask_width / 2) - 1 && i <= width - mask_width / 2)
    {
        for (int j = -mask_width / 2; j <= mask_width / 2; j++)
            sum += N[i + j] * M[j + mask_width / 2];
        P[i] = sum;
    }
}

int main()
{
    int width, mask_width;

    printf("Enter width: ");
    scanf("%d", &width);

    printf("Enter mask width: ");
    scanf("%d", &mask_width);

    int N[width], M[mask_width], P[width];

    printf("Enter elements for array N:\n");
    for (int i = 0; i < width; i++)
        scanf("%d", &N[i]);

    printf("Enter elements for mask array M:\n");
    for (int i = 0; i < mask_width; i++)
        scanf("%d", &M[i]);

    int *d_n, *d_m, *d_p;
    int n = sizeof(int) * width, m = sizeof(int) * mask_width;

    cudaMalloc((void **)&d_n, n);
    cudaMalloc((void **)&d_m, m);
    cudaMalloc((void **)&d_p, n);

    cudaMemcpy(d_n, N, n, cudaMemcpyHostToDevice);
    cudaMemcpy(d_m, M, m, cudaMemcpyHostToDevice);

    dim3 dimGrid(width, 1, 1);
    dim3 dimBlock(256, 1, 1);

    conv<<<dimGrid, dimBlock>>>(d_n, width, d_m, mask_width, d_p);

    cudaMemcpy(P, d_p, n, cudaMemcpyDeviceToHost);

    printf("Output:\n");
    for (int i = 0; i < width; i++)
        printf("%d ", P[i]);
    printf("\n");

    cudaFree(d_n);
    cudaFree(d_m);
    cudaFree(d_p);

    return 0;
}