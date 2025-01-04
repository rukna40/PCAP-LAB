#include <stdio.h>
#include <mpi.h>

int main(int argc, char* argv[]){
    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    char str[]="HelLO";
    if (65<=str[rank]&& str[rank]<=90){
        str[rank]+=32;
    }
    else if(97<=str[rank]&& str[rank]<=122){
        str[rank]-=32;
    }
    printf("Rank %d: %s\n",rank,str);
    MPI_Finalize();
    return 0;
}