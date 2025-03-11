#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void multiplyrow(int n, int m, int p, int *mat1, int *mat2, int *res)
{
    int row = threadIdx.x + blockDim.x * blockIdx.x;
    if (row < n)
    {
        for (int col = 0; col < p; col++)
        {
            int sum = 0;
            for (int k = 0; k < m; k++)
            {
                sum += mat1[row * m + k] * mat2[k * p + col];
            }
            res[row * p + col] = sum;
        }
    }
}

__global__ void multiplycol(int n, int m, int p, int *mat1, int *mat2, int *res)
{
    int col = threadIdx.x + blockDim.x * blockIdx.x;
    if (col < n)
    {
        for (int row = 0; row < n; row++)
        {
            int sum = 0;
            for (int k = 0; k < m; k++)
            {
                sum += mat1[row * m + k] * mat2[k * p + col];
            }
            res[row * p + col] = sum;
        }
    }
}

__global__ void multiplyele(int n, int m, int p, int *mat1, int *mat2, int *res)
{
    int idx = threadIdx.y + blockDim.y * blockIdx.y;

    if (idx < n * p)
    {
        int row = idx / p;
        int col = idx % p;

        int sum = 0;

        for (int k = 0; k < m; k++)
        {
            sum += mat1[row * m + k] * mat2[k * p + col];
        }
        res[row * p + col] = sum;
    }
}

int main()
{
    int n, m, p;
    printf("Enter n: ");
    scanf("%d", &n);
    printf("Enter m: ");
    scanf("%d", &m);
    printf("Enter p: ");
    scanf("%d", &p);

    int mat1[n][m], mat2[m][p], res[n][p];

    printf("Enter elements for matrix 1:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            scanf("%d", &mat1[i][j]);
        }
    }

    printf("Enter elements for matrix 2:\n");
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < p; j++)
        {
            scanf("%d", &mat2[i][j]);
        }
    }

    int *d_m1, *d_m2, *d_res;
    cudaMalloc((void **)&d_m1, sizeof(int) * n * m);
    cudaMalloc((void **)&d_m2, sizeof(int) * m * p);
    cudaMalloc((void **)&d_res, sizeof(int) * n * p);

    cudaMemcpy(d_m1, mat1, sizeof(int) * n * m, cudaMemcpyHostToDevice);
    cudaMemcpy(d_m2, mat2, sizeof(int) * m * p, cudaMemcpyHostToDevice);

    multiplyrow<<<n, m>>>(n, m, p, d_m1, d_m2, d_res);

    cudaMemcpy(res, d_res, sizeof(int) * n * p, cudaMemcpyDeviceToHost);

    printf("Row wise result:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < p; j++)
        {
            printf("%d\t", res[i][j]);
        }
        printf("\n");
    }

    multiplycol<<<n, m>>>(n, m, p, d_m1, d_m2, d_res);

    cudaMemcpy(res, d_res, sizeof(int) * n * p, cudaMemcpyDeviceToHost);

    printf("Column wise Result:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < p; j++)
        {
            printf("%d\t", res[i][j]);
        }
        printf("\n");
    }

    multiplyele<<<n, m>>>(n, m, p, d_m1, d_m2, d_res);

    cudaMemcpy(res, d_res, sizeof(int) * n * p, cudaMemcpyDeviceToHost);

    printf("Element wise result:\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < p; j++)
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