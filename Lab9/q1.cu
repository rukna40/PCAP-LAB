#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void csr_mv(int *r, int *c, float *v, float *vec, float *res, int rows) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < rows) {
        float sum = 0;
        for (int i = r[row]; i < r[row + 1]; i++) {
            sum += v[i] * vec[c[i]];
        }
        res[row] = sum;
    }
}

int main() {
    int rows, cols, nze, *row_ptr, *col_idx;
    float *values, *vec, *res;

    printf("Enter number of rows, columns, non-zero elements: ");
    scanf("%d %d %d", &rows, &cols, &nze);

    values = (float *)malloc(nze * sizeof(float)); 
    row_ptr = (int *)calloc(rows + 1, sizeof(int));
    col_idx = (int *)malloc(nze * sizeof(int));
    
    printf("Enter sparse matrix (row col value):\n");
    for (int i = 0; i < nze; i++) {
        int row, col;
        float value;
        scanf("%d %d %f", &row, &col, &value);
        row_ptr[row + 1]++; 
        values[i] = value; 
        col_idx[i] = col; 
    }

    for (int i = 1; i <= rows; i++) {
        row_ptr[i] += row_ptr[i - 1];
    }

    vec = (float *)malloc(cols * sizeof(float));
    res = (float *)calloc(rows, sizeof(float));

    printf("Enter vector elements:\n");
    for (int i = 0; i < cols; i++) {
        scanf("%f", &vec[i]);
    }

    int *dr, *dc;
    float *dv, *dvec, *dres;

    cudaMalloc(&dr, (rows + 1) * sizeof(int));
    cudaMalloc(&dc, nze * sizeof(int));
    cudaMalloc(&dv, nze * sizeof(float));
    cudaMalloc(&dvec, cols * sizeof(float));
    cudaMalloc(&dres, rows * sizeof(float));

    cudaMemcpy(dr, row_ptr, (rows + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dc, col_idx, nze * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dv, values, nze * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dvec, vec, cols * sizeof(float), cudaMemcpyHostToDevice);

    int bs = 256;
    int gs = (rows + bs - 1) / bs;
    csr_mv<<<gs, bs>>>(dr, dc, dv, dvec, dres, rows);

    cudaMemcpy(res, dres, rows * sizeof(float), cudaMemcpyDeviceToHost);

    printf("\nResult:\n");
    for (int i = 0; i < rows; i++) {
        printf("%f ", res[i]);
    }
    printf("\n");

    cudaFree(dr);
    cudaFree(dc);
    cudaFree(dv);
    cudaFree(dvec);
    cudaFree(dres);

    free(row_ptr);
    free(col_idx);
    free(values);
    free(vec);
    free(res);

    return 0;
}