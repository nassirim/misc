// Author: Mohammad Nassiri
// Polytechnique Montreal
// A simple code to 
// 	1- taint a pointer 
// 	2- catch the SIGSEGV signal, then remove the tag and access the memory
// It only works in the user-space 


#include <stdint.h>
#include <stdio.h>
#include <setjmp.h>
#include <signal.h>
#include <string.h>


sigjmp_buf point;

static void handler(int sig, siginfo_t *si, void *unused)
{
	longjmp(point, 1);
}

void print_pointer(uintptr_t addr, const char *msg) {

	uintptr_t i = (1ULL << (sizeof(addr)*8-1));
	int j = 16;

	printf("%20s: %20p  Binary: ", msg, (int *)addr);
	for(; i; i >>= 1) {
		if (j == 0) printf(" :: "); // as seperator between 16 MSB and 48 LSB
		printf("%d",(addr & i)!=0);
		j--;
	}

	printf("\n");
}

int main() {
	struct sigaction sa;

	memset(&sa, 0, sizeof(sigaction));
	sigemptyset(&sa.sa_mask);

	sa.sa_flags     = SA_NODEFER;
	sa.sa_sigaction = handler;

	sigaction(SIGSEGV, &sa, NULL);


	int val = 15;

	int *p1 = &val; // original pointer
	uint16_t tag_data = 12345; // This is the tag to store in the top 16 bits 
	const uintptr_t MASK = ~(65535ULL << 48);
    

	// Store the tag into the pointer
	int *p2 = (int *)(((uintptr_t)p1 & MASK) | ((uintptr_t)tag_data << 48));

	// Retrieve the tag data stored in the tainted pointer
	tag_data = (uintptr_t)p2 >> 48;
	printf("TAG value is %d \n", tag_data);

	// Deference the pointer
	int *p3 = (int *)(((intptr_t)p2 << 16) >> 16);

	print_pointer(MASK, "MASK");
	print_pointer(p1, "Original pointer");
	print_pointer(p2, "Tainted pointer");
//	print_pointer(p3, "Dereferenced pointer");

	printf("Access the memory via original pointer : %d \n", *p1);

	if (setjmp(point) == 0) {
		printf("Access the memory via the tainted pointer ... \n");
		printf("The content is : %d \n", *p2); // causes a SIGSEGV 
	}
	else {
		printf("SIGSEGV was catched ...\n");
		printf("Removing the tag and access the memory via the same pointer again... \n");
		// Deference the pointer
		p2 = (((intptr_t)p2 << 16) >> 16);
		printf("The content is : %d \n", *p2);
	}

	return 0;
}
