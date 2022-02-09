# Misc programs

# Pointer Tainting - taint_test.c
This is a C program to insert a tag into the most significant 16 bits of a pointer. 
When I access the memory through the tainted pointer, a SIGSESV signal is raised.  
I also developed a signal handler that catches this signal and then removes the tag so the memory address could be accessed through the same pointer.

To compile the code 
gcc -o taint_test taint_test.c

# SymbolicInfo Resolver
Extract the offset of each symbolic information. Here I take the symbolic name for the function pthread_mutex_lock as an example.

This example shows how to extract the virtual address for the function pthread_mutex_lock
  cat /proc/$(pidof test)/maps > maps.dump  --- at runtime!
  1- extract the base virtual address of libthread shared library
  cat maps.dump | grep -m 1 libpthread | awk -F'-' '{print $1}'
  ---7f1901354000-7f190135b000 r--p 00000000 103:02 12722317                  /usr/lib/x86_64-linux-gnu/libpthread-2.31.so

  ---7f1901354000 is the base virtual address of libthread shared library : 
  I use this address to compute the virtual address of pthread_mutex_lock and pthread_mutex_unlock

  2- extract the offset address of the function pthread_mutex_lock
  readelf -s /usr/lib/x86_64-linux-gnu/libpthread-2.31.so | awk -F' ' '$8=="pthread_mutex_lock"'  | awk -F' ' '{print $2}'

  the output is : 000000000000bfc0
  3- add bothe above address to compute the virtual address for function pthread_mutex_lock 
   the result is : 7f1901354000 + 000000000000bfc0 = 7F190135FFC0
 
