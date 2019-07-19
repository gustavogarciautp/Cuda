#!/bin/bash
for k in {1..5}
do
	for j in {5..10}
	do
		for i in {50 200 400 600 800 1000 3000 5000 8000 10000 40000 70000 100000 200000 500000 800000 1000000}
		do
			./cuda $i $j >> resultado.csv
		done
	done
done
