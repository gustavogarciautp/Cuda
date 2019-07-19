#!/bin/bash
for k in  {1..5}
do
	for j in {5..10}
	do
		for i in {50 100 300 500 800 1000 1300 5000 8000 10000 50000 80000 100000 300000 500000 800000 1000000}
		do
			./cuda $i $j >> resultado2.csv
		done
	done
done

