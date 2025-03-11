#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void addrow(int n, int m, int *mat1, int *mat2, int *res)
{
    int row = threadIdx.x + blockDim.x * blockIdx.x;
    if (row < n)
    {
        for (int j = 0; j < m; j++)
        {
            res[row * m + j] = mat1[row * m + j] + mat2[row * m + j];
        }
    }
}

__global__ void addcol(int n, int m, int *mat1, int *mat2, int *res)
{
    int col = threadIdx.x + blockDim.x * blockIdx.x;
    if (col < m)
    {
        for (int i = 0; i < n; i++)
        {
            res[i * m + col] = mat1[i * m + col] + mat2[i * m + col];
        }
    }
}

__global__ void addele(int n, int m, int *mat1, int *mat2, int *res)
{
    int idx = threadIdx.x + blockDim.x * blockIdx.x;
    if (idx < n * m)
    {
        res[idx] = mat1[idx] + mat2[idx];
    }
}

int main()
{
    int n, m;
    printf("Enter n: ");
    scanf("%d", &n);
    printf("Enter m: ");
    scanf("%d", &m);

    int mat1[n][m], mat2[n][m], res[n][m];

    printf("Enter elements for matrix 1:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            scanf("%d", &mat1[i][j]);
        }
    }

    printf("Enter elements for matrix 2:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            scanf("%d", &mat2[i][j]);
        }
    }

    int *d_m1, *d_m2, *d_res;
    cudaMalloc((void **)&d_m1, sizeof(int) * n * m);
    cudaMalloc((void **)&d_m2, sizeof(int) * n * m);
    cudaMalloc((void **)&d_res, sizeof(int) * n * m);

    cudaMemcpy(d_m1, mat1, sizeof(int) * m * n, cudaMemcpyHostToDevice);
    cudaMemcpy(d_m2, mat2, sizeof(int) * m * n, cudaMemcpyHostToDevice);

    addrow<<<n, m>>>(n, m, d_m1, d_m2, d_res);

    cudaMemcpy(res, d_res, sizeof(int) * m * n, cudaMemcpyDeviceToHost);

    printf("Row wise result:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            printf("%d\t", res[i][j]);
        }
        printf("\n");
    }

    addcol<<<n, m>>>(n, m, d_m1, d_m2, d_res);

    cudaMemcpy(res, d_res, sizeof(int) * m * n, cudaMemcpyDeviceToHost);

    printf("Column wise Result:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            printf("%d\t", res[i][j]);
        }
        printf("\n");
    }

    addele<<<n, m>>>(n, m, d_m1, d_m2, d_res);

    cudaMemcpy(res, d_res, sizeof(int) * m * n, cudaMemcpyDeviceToHost);

    printf("Element wise result:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            printf("%d\t", res[i][j]);
        }
        printf("\n");
    }

    cudaFree(d_m1);
    cudaFree(d_m2);
    cudaFree(d_res);

    return 0;
}