#include <stdio.h>
#include <mpi.h>
#include <math.h>

int main(int argc, char* argv[]){
    int rank,size;
    int a=5,b=3;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    switch (rank){
        case 0:
            printf("Rank %d (Add): %d\n",rank,a+b);
            break;
        case 1:
            printf("Rank %d (Subtract): %d\n",rank,a-b);
            break;
        case 2:
            printf("Rank %d (Multiply): %d\n",rank,a*b);
            break;
        case 3:
            printf("Rank %d (Divide): %.2f\n",rank,(float)a/b);
            break;
        default:
            break;
    } 
    MPI_Finalize();
    return 0;
}