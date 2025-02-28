#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void repeat_string(char* input, char* output, int str_len, int total_len) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < total_len) {
        int repeat_idx = idx % str_len;
        output[idx] = input[repeat_idx];
    }
}

int main() {
    const char* input_string = "PCAP";
    int str_len = strlen(input_string);
    int total_len = 9;

    char* d_input;
    char* d_output;

    cudaMalloc((void**)&d_input, str_len + 1);
    cudaMalloc((void**)&d_output, total_len + 1);

    cudaMemcpy(d_input, input_string, str_len + 1, cudaMemcpyHostToDevice);

    dim3 dimGrid(width, 1, 1);
    dim3 dimBlock(256, 1, 1);

    repeat_string<<<dimGrid, dimBlock>>>(d_input, d_output, str_len, total_len);

    char output_string[total_len + 1];
    cudaMemcpy(output_string, d_output, total_len + 1, cudaMemcpyDeviceToHost);

    printf("Input string: %s\n", input_string);
    printf("Output string: %s\n", output_string);

    cudaFree(d_input);
    cudaFree(d_output);

    return 0;
}
