#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[])
{
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Status status;
    int n;
    if (rank == 0)
    {
        printf("Enter number: ");
        scanf("%d", &n);
        MPI_Send(&n, 1, MPI_INT, rank + 1, 1, MPI_COMM_WORLD);
        MPI_Recv(&n, 1, MPI_INT, size - 1, 1, MPI_COMM_WORLD, &status);
        printf("Rank %d: Message Recieved = %d\n", rank, n);
    }
    else
    {
        MPI_Recv(&n, 1, MPI_INT, rank - 1, 1, MPI_COMM_WORLD, &status);
        printf("Rank %d: Message Recieved = %d\n", rank, n);
        n = n + 1;
        int dest;
        if (rank == size - 1)
            dest = 0;
        else
            dest = rank + 1;
        MPI_Send(&n, 1, MPI_INT, dest, 1, MPI_COMM_WORLD);
    }
    MPI_Finalize();
    return 0;
}