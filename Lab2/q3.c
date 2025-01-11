#include <stdio.h>
#include <mpi.h>

#define n 11

int main(int argc, char *argv[])
{
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Status status;

    int arr[n], buff[sizeof(int) + MPI_BSEND_OVERHEAD];
    MPI_Buffer_attach(buff, sizeof(buff));

    if (rank == 0)
    {
        printf("Enter numbers:\n");
        for (int i = 1; i < size; i++)
            scanf("%d", &arr[i]);
        for (int i = 1; i < size; i++)
            MPI_Bsend(&arr[i], 1, MPI_INT, i, 1, MPI_COMM_WORLD);
    }
    else
    {
        int num;
        MPI_Recv(&num, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        printf("Rank %d: Message Recieved = %d\n", rank, num);
        if (rank%2==0)
            printf("Square = %d\n",num*num);
        else
            printf("Cube = %d\n",num*num*num);
    }

    MPI_Buffer_detach(&buff, &size);

    MPI_Finalize();
    return 0;
}