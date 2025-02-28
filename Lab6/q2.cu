#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void selection_sort(int *arr, int n) {
    int i = threadIdx.x + blockDim.x * blockIdx.x;

    if (i < n) {
        int pos = 0;
        for (int j = 0; j < n; j++) {
            if (arr[j] < arr[i]) {
                pos++;
            }
        }

        arr[pos] = arr[i];
    }
}

int main()
{
    int n;

    printf("Enter n: ");
    scanf("%d", &n);

    int arr[n];

    printf("Enter elements for array:\n");
    for (int i = 0; i < n; i++)
        scanf("%d", &arr[i]);

    int *d_arr;

    cudaMalloc((void **)&d_arr, sizeof(int)*n);

    cudaMemcpy(d_arr, arr, sizeof(int)*n, cudaMemcpyHostToDevice);

    dim3 dimGrid(n, 1, 1);
    dim3 dimBlock(1, 1, 1);

    selection_sort<<<dimGrid, dimBlock>>>(d_arr, n);

    cudaMemcpy(arr, d_arr, sizeof(int) * n, cudaMemcpyDeviceToHost);

    printf("Output:\n");
    for (int i = 0; i < n; i++)
        printf("%d ", arr[i]);
    printf("\n");

    cudaFree(d_arr);
    return 0;
}