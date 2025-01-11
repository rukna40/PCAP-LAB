#include <stdio.h>
#include <mpi.h>
#include <string.h>

#define n 11

int main(int argc, char *argv[])
{
    int rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Status status;
    char string[n];
    if (rank == 0)
    {
        fprintf(stdout,"Enter word: ");
        scanf("%s", string);
        MPI_Ssend(&string, strlen(string) + 1, MPI_CHAR, 1, 1, MPI_COMM_WORLD);
        fprintf(stdout,"Rank %d: Message Sent\n", rank);
        MPI_Recv(&string, n, MPI_CHAR, 1, 2, MPI_COMM_WORLD, &status);
        fprintf(stdout,"Rank %d: Message Received\n%s\n", rank, string);
        fflush(stdout);
    }
    else if (rank == 1)
    {
        MPI_Recv(&string, n, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &status);
        fprintf(stdout,"Rank %d: Message Received\n%s\n", rank, string);
        for (int i = 0; i < strlen(string); i++)
        {
            if (65<=string[i]&& string[i]<=90){
                string[i]+=32;
            }
            else if(97<=string[i]&& string[i]<=122){
                string[i]-=32;
            }
        }
        MPI_Ssend(&string, strlen(string) + 1, MPI_CHAR, 0, 2, MPI_COMM_WORLD);
        fprintf(stdout,"Rank %d: Message Sent\n", rank);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
