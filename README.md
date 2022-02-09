# Misc programs

# Pointer Tainting
This is a C program to insert a tag into the most significant 16 bits of a pointer. 
When I access the memory through the tainted pointer, a SIGSESV signal is raised.  
I also developed a signal handler that catches this signal and then removes the tag so the memory address could be accessed through the same pointer.

To compile the code 
gcc -o taint_test taint_test.c
