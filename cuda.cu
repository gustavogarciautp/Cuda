#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <random>
#include <chrono>
#include "common.h"

using namespace std;

__global__ void simulation(int *actual, int *next, int N, int tam, int *move) {
	int index = threadIdx.x + blockIdx.x * N;

	int i_act = actual[index];
	int i_ant = actual[index-1];
	int i_next =actual[index+1];

	if (index==0){
		i_ant = actual[tam-1];
	}

	if (index== tam-1){
		i_next = actual[0];
	}

	int val=0;
	if (i_act==0){
		if (i_ant==1){
			val=1;
		}
		else{
			val= 0;
		}
	}
	else{
		if (i_next==1){
			val= 1;
		}
		else{
			val= 0;
		}
	}

	next[index] = val;
	if (actual[index]==0 && val==1){
		atomicAdd(move, 1);
	}
}

/*
float cspeed(int *actual, int *next, int tam){
	float speed = 0.0;
	for(int i=0;i<tam;i++){
		if(actual[i]==0 && next[i]==1){
			speed+=1.0;
		}
	}
	return speed;
}
*/

int main(int argc, char *argv[]){
	int *actual, *next;
	//float speed = 0.0;
	int tam = atoi(argv[1]);
	int iterations = atoi(argv[2]);
	int *mov;
	//printf("Tam %d\n", tam);
	//printf("Ite %d\n",iterations);
	int size = tam * sizeof(int);

	int *d_actual, *d_next, *d_mov;

	CHECK(cudaMalloc((int **)&d_actual, size));
	CHECK(cudaMalloc((int **)&d_next, size));
	CHECK(cudaMalloc((int **)&d_mov, sizeof(int)))

	actual = (int *)malloc(size);
	next = (int *)malloc(size);
	mov = (int *)malloc(sizeof(int));

	int value;
	float cars =0.0;

	for (int i=0; i<tam; i++){
		value= rand () % (2);
		actual[i]= value;
		cars+=value;
	}

   	memset(next, 0, size);
   	memset(mov, 0, sizeof(int));
	
   	CHECK(cudaMemcpy(d_actual, actual, size, cudaMemcpyHostToDevice));
   	CHECK(cudaMemcpy(d_next, next, size, cudaMemcpyHostToDevice));
   	CHECK(cudaMemcpy(d_mov, mov, sizeof(int), cudaMemcpyHostToDevice));

	std::chrono::steady_clock::time_point _start(std::chrono::steady_clock::now());
	for(int i=0; i<iterations; i++){


		simulation<<<tam/10,10>>>(d_actual, d_next, 10, tam, d_mov);

		/*if (i==0){
			CHECK(cudaMemcpy(actual, d_actual, size, cudaMemcpyDeviceToHost));

			for (int j=0; j<tam; j++){
	   			printf("%d  ", actual[j]);
	   		}
	   		printf("\n");
		}*/

	   	//CHECK(cudaMemcpy(next,d_next, size, cudaMemcpyDeviceToHost));
	   	CHECK(cudaMemcpy(d_actual, d_next, size, cudaMemcpyDeviceToDevice));
	   	CHECK(cudaMemcpy(mov, d_mov, sizeof(int), cudaMemcpyDeviceToHost));
		
		/*
		speed=cspeed(actual,next,tam);

		CHECK(cudaMemcpy(actual,d_next, size, cudaMemcpyDeviceToHost));
		
			
	   	for (int j=0; j<tam; j++){
	   		printf("%d  ", next[j]);
	   	}*/
	   	printf("%f,",*mov/cars);
	   	CHECK(cudaMemset(d_mov,0,sizeof(int)));
	}
	std::chrono::steady_clock::time_point _end(std::chrono::steady_clock::now());
	std::cout << std::chrono::duration_cast<std::chrono::duration<double>>(_end - _start).count();
	printf("\n");
	free(actual);
	free(next);
	CHECK(cudaFree(d_actual));
	CHECK(cudaFree(d_next));

	return 0;
}
