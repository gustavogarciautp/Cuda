#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "mpi.h"
#include <iostream>
#include <random>

using namespace std;

#define MASTER 0        /* task ID of master task */

int update(int ant, int act, int next){
	if (act==0){
		if (ant==1){
			return 1;
		}
		else{
			return 0;
		}
	}
	else{
		if (next==1){
			return 1;
		}
		else{
			return 0;
		}
	}
}

int main (int argc, char *argv[]){
	int tam = atoi(argv[1]);        
  	int iterations = atoi(argv[2]);
  	int taskid,         
    	numtasks,       /* number of tasks */
    	dest, source;   
		MPI_Status Stat;

	int *vector = (int*) malloc(tam * sizeof(int) );

	int value, cars=0;
	for (int i=0; i<tam; i++){
		value= rand () % (2);
		vector[i]= value;
		cars+=value;
	}

	double t1, t2,tf;
    	t1=MPI_Wtime();

	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&numtasks);
	MPI_Comm_rank(MPI_COMM_WORLD,&taskid);

	/*if (taskid==MASTER){
		for (int i=0; i<tam; i++){
			printf("%d  ", vector[i]);
		}
		printf("\n");
	}*/
	  
	int cant = tam/(numtasks-1);
	if (taskid == MASTER) {
		for (int k=0; k<iterations; k++){
			float speed =0.0;
		  	for (int i=0; i< numtasks-1; i++){
			    
			    dest = i+1;
			    
			    int num=cant;
			    
			    if (i == numtasks-2)
		     		num = tam - i*cant;
		     	
		     	int c[num+2];
		     	memset(c, 0, (num+2) * sizeof(int));
			    memcpy(&c[1], vector+cant*i, (num)*sizeof(int));


			    if (i==0){
			    	c[0]= vector[tam-1];
			    }
			    else{
			     	c[0]= vector[i*cant-1];
			    }

			    if (i== numtasks-2){
			     	c[num+1]= vector[0];
			    }
			    else{
			     	c[num+1]= vector[(i+1)*cant];
			    }

			    MPI_Send(&c, num+2, MPI_INT, dest, 1, MPI_COMM_WORLD);
		 		}
		 	
		 	//int vector_new[tam];
		 	for (int i=0; i<numtasks -1; i++){
		     	source = i+1;
		     	
		     	int num=cant;

		     	if (i == numtasks-2)
		     		num = tam - i*cant;

		     	int d[num];
		 		int vel;
		 		MPI_Recv(&d, num, MPI_INT, source, 1, MPI_COMM_WORLD, &Stat);
		 		MPI_Recv(&vel, 1, MPI_INT, source, 2, MPI_COMM_WORLD, &Stat);
				memcpy(&vector[i*cant], d, (num)*sizeof(int));

				speed+=vel;

		 	}
		 	/*for (int j=0; j<tam; j++){
				printf("%d ", vector[j]);
			}
			printf("\n");*/

			printf("Velocidad %f\n", speed/cars);
		}
	}     
	else {
	   	for (int m=0; m<iterations; m++){
		    dest = 0;
		    source = 0;
		    
		    int num=cant;

			if (taskid == numtasks-1)
		    	num = tam - (taskid-1)*cant;		    
		    //printf("cantidad %d\n", num);

		    int recv[num+2];
		    MPI_Recv(&recv, num+2, MPI_INT, source, 1, MPI_COMM_WORLD, &Stat);

		    int velocidad=0;
	        int next_t[num];
		    for (int i=1; i<num+1; i++){
		     	next_t[i-1]=update(recv[i-1], recv[i], recv[i+1]);
		     	/*if (taskid==1){
		     		printf("Valores %d %d %d\n", recv[i-1], recv[i], recv[i+1]);
		     	}*/
		     	if (recv[i]==0 && next_t[i-1]==1){
		     		velocidad= velocidad+1;
		     	}

		    } 

		    MPI_Send(&next_t, num, MPI_INT, dest, 1, MPI_COMM_WORLD);
		    MPI_Send(&velocidad, 1, MPI_INT, dest, 2, MPI_COMM_WORLD);

		}
	}

	MPI_Finalize(); 


	if (taskid== MASTER){
    	t2=MPI_Wtime();
    	tf=t2-t1;  
   		printf("Time %.11f\n", tf);  
	}
	return 0;
}
