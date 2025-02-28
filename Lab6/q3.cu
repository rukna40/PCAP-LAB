#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void odd(int *arr, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i % 2 == 1 && i < n - 1)
    {
        if (arr[i] > arr[i + 1])
        {
            int temp = arr[i];
            arr[i] = arr[i + 1];
            arr[i + 1] = temp;
        }
    }
}

__global__ void even(int *arr, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i % 2 == 0 && i < n - 1)
    {
        if (arr[i] > arr[i + 1])
        {
            int temp = arr[i];
            arr[i] = arr[i + 1];
            arr[i + 1] = temp;
        }
    }
}

int main()
{
    int n;

    printf("Enter n: ");
    scanf("%d", &n);

    int *arr = (int *)malloc(sizeof(int) * n);

    printf("Enter elements for array:\n");
    for (int i = 0; i < n; i++)
    {
        scanf("%d", &arr[i]);
    }

    int *d_arr;

    cudaMalloc((void **)&d_arr, sizeof(int) * n);

    cudaMemcpy(d_arr, arr, sizeof(int) * n, cudaMemcpyHostToDevice);

    dim3 dimGrid(n, 1, 1);
    dim3 dimBlock(1, 1, 1);

    for (int i = 0; i < n; i++)
    {
        even<<<dimGrid, dimBlock>>>(d_arr, n);
        odd<<<dimGrid, dimBlock>>>(d_arr, n);
    }

    cudaMemcpy(arr, d_arr, sizeof(int) * n, cudaMemcpyDeviceToHost);

    printf("Sorted Output:\n");
    for (int i = 0; i < n; i++)
    {
        printf("%d ", arr[i]);
    }
    printf("\n");

    cudaFree(d_arr);

    free(arr);

    return 0;
}
