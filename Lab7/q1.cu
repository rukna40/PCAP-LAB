#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void count_word(char* sentence, char* word, int* count, int sentence_len, int word_len) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < sentence_len - word_len + 1) {
        bool match = true;
        for (int i = 0; i < word_len; ++i) {
            if (sentence[idx + i] != word[i]) {
                match = false;
                break;
            }
        }

        if (match) {
            atomicAdd(count, 1);
        }
    }
}

int main() {
    const char* sentence = "This is a test sentence, and this is a test";
    const char* word = "test";
    
    int sentence_len = strlen(sentence);
    int word_len = strlen(word);
    int count = 0;

    char* d_sentence;
    char* d_word;
    int* d_count;

    cudaMalloc((void**)&d_sentence, sentence_len + 1);
    cudaMalloc((void**)&d_word, word_len + 1);
    cudaMalloc((void**)&d_count, sizeof(int));

    cudaMemcpy(d_sentence, sentence, sentence_len + 1, cudaMemcpyHostToDevice);
    cudaMemcpy(d_word, word, word_len + 1, cudaMemcpyHostToDevice);
    cudaMemcpy(d_count, &count, sizeof(int), cudaMemcpyHostToDevice);

    dim3 dimGrid(width, 1, 1);
    dim3 dimBlock(256, 1, 1);

    count_word<<<dimGrid, dimBlock>>>(d_sentence, d_word, d_count, sentence_len, word_len);

    cudaMemcpy(&count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

    printf("The word '%s' appears %d times in the sentence.\n", word, count);

    cudaFree(d_sentence);
    cudaFree(d_word);
    cudaFree(d_count);

    return 0;
}
