#include <stdio.h>
#include <mpi.h>

int factorial(int n){
    if (n<=1)
        return 1;
    return n*factorial(n-1);
}

int fibo(int n){
    if (n<=1)
        return n;
    return fibo(n-1)+fibo(n-2);
}

int main(int argc, char* argv[]){
    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    if (rank%2==0)
        printf("Rank %d: Factorial = %d\n",rank,factorial(rank));
    else
        printf("Rank %d: Fibo = %d\n",rank,fibo(rank));
    MPI_Finalize();
    return 0;
}