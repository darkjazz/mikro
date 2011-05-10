/*
 main.cpp
 mikro
 
 This file is part of mikro.
 
 mikro:strukt is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 mikro:strukt is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with mikro:strukt.  If not, see <http://www.gnu.org/licenses/>. 
 
*/

#include <iostream>
#include <string>
#include <stdlib.h>

#include "mikro.h"

int main (int argc, char * const argv[]) {
	
	int sX = NULL, sY = NULL, debug = NULL, width = NULL, height = NULL, fr = NULL, vs = NULL, td = NULL;
	double lr = NULL;
	const char *ip, *port; 
	char* arg;
	
	
	for (int i = 1; i < argc; i++) {
		if (argc != i + 1) {
			arg = argv[i+1];
			// world size x-axis
			if (strcmp(argv[i], "-x") == 0) {
				sX = atoi(argv[i+1]);
			}
			// world size y-axis
			else if (strcmp(argv[i], "-y") == 0) {
				sY = atoi(argv[i+1]);
			}
			// debug mode - 1 makes window on current screen
			else if (strcmp(argv[i], "-d") == 0) {
				debug = atoi(argv[i+1]);
			}
			// window width
			else if (strcmp(argv[i], "-w") == 0) {
				width = atoi(argv[i+1]);
			}
			// window height
			else if (strcmp(argv[i], "-h") == 0) {
				height = atoi(argv[i+1]);
			}
			// frame rate per second
			else if (strcmp(argv[i], "-f") == 0) {
				fr = atoi(argv[i+1]);
			}
			// supercollider host ip
			else if (strcmp(argv[i], "-i") == 0) {
				ip = argv[i+1];
			}
			// supercollider host port - normally 57120
			else if (strcmp(argv[i], "-p") == 0) {
				port = argv[i+1];
			}
			// som vector size
			else if (strcmp(argv[i], "-s") == 0) {
				vs = atoi(argv[i+1]);
			}
			// som training duration
			else if (strcmp(argv[i], "-t") == 0) {
				td = atoi(argv[i+1]);
			}
			// som learning rate
			else if (strcmp(argv[i], "-l") == 0) {
				lr = atof(argv[i+1]);
			}
		}
	}
	
	runApp(sX, sY, debug, width, height, fr, ip, port, vs, td, lr);

    return 0;
	
}
