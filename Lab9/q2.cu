#include <stdio.h>
#include <cuda_runtime.h>
#include <math.h>

__global__ void powers(int *d_A, int M, int N)
{
    int row = threadIdx.x + blockDim.x * blockIdx.x;
    if (row < M)
    {
        for (int col = 0; col < N; col++)
        {
            if (row == 0)
                d_A[row * N + col] = d_A[row * N + col];
            else
                d_A[row * N + col] = pow(d_A[row * N + col], row + 1);
        }
    }
}

int main()
{
    int M, N;

    printf("Enter the number of rows (M): ");
    scanf("%d", &M);
    printf("Enter the number of columns (N): ");
    scanf("%d", &N);

    int *h_A = (int *)malloc(M * N * sizeof(int));

    printf("Enter the elements of the matrix (%d elements):\n", M * N);
    for (int i = 0; i < M; i++)
    {
        for (int j = 0; j < N; j++)
        {
            scanf("%d", &h_A[i * N + j]);
        }
    }

    int *d_A;
    size_t size = M * N * sizeof(int);
    cudaMalloc((void **)&d_A, size);
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

    powers<<<M, 1>>>(d_A, M, N);

    cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);
    cudaFree(d_A);

    printf("Modified Matrix:\n");
    for (int i = 0; i < M; i++)
    {
        for (int j = 0; j < N; j++)
        {
            printf("%d ", h_A[i * N + j]);
        }
        printf("\n");
    }

    free(h_A);

    return 0;
}