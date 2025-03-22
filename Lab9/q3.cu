#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__device__ int ones_complement(int n) {
    int bin=0;
    int inc=1;
    for(int i = n; i > 0; i /= 2) {
        bin += (i%2 == 0)*inc;
        inc *= 10;
    }
    return bin;
}

__global__ void non_border_complement(int *mat, int *out, int rows, int cols) {
    int r = blockIdx.x * blockDim.x + threadIdx.x;
    int c = blockIdx.y * blockDim.y + threadIdx.y;

    if(r < rows && c < cols) {
        int elem;
        if (r == 0 || r == rows-1 || c == 0 || c == cols-1) {
            elem = mat[r*cols + c];
        } else {
            elem = ones_complement(mat[r*cols + c]);
        }
        out[r*cols + c] = elem;
    }
}

int main() {
    int r, c;
    printf("Rows: ");
    scanf("%d", &r);
    printf("Columns: ");
    scanf("%d", &c);

    int mat[r][c], out[r][c];

    printf("Enter matrix:\n");
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            scanf("%d", &mat[i][j]);
        }
    }

    int *d_mat, *d_out;
    cudaMalloc((void **)&d_mat, r * c * sizeof(int));
    cudaMalloc((void **)&d_out, r * c * sizeof(int));

    cudaMemcpy(d_mat, mat, r * c * sizeof(int), cudaMemcpyHostToDevice);

    non_border_complement<<<dim3(ceil(r/32.0), ceil(c/32.0)), dim3(32, 32)>>>(d_mat, d_out, r, c);
    cudaMemcpy(out, d_out, r * c * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Result:\n");
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            printf("%d ", out[i][j]);
        }
        printf("\n");
    }

    cudaFree(d_mat);
    cudaFree(d_out);
    return 0;
}