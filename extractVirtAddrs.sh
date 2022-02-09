######################
#   Mohammad Nassiri
#   December 15 2021
######################
prog="test"
tmpfile="tmp.txt"

cat /proc/$(pidof test)/maps > maps.dump

#Extract the offset of each global variable

# This example shows how to extract the virtual address for the function pthread_mutex_lock
#
#  cat /proc/$(pidof test)/maps > maps.dump  --- at runtime!
#
#  1- extract the base virtual address of libthread shared library
#  cat maps.dump | grep -m 1 libpthread | awk -F'-' '{print $1}'
#  #  7f1901354000-7f190135b000 r--p 00000000 103:02 12722317                  /usr/lib/x86_64-linux-gnu/libpthread-2.31.so
#
#  7f1901354000 is the base virtual address of libthread shared library : 
#  I use this address to compute the virtual address of pthread_mutex_lock and pthread_mutex_unlock
#
#  2- extract the offset address of the function pthread_mutex_lock
#  readelf -s /usr/lib/x86_64-linux-gnu/libpthread-2.31.so | awk -F' ' '$8=="pthread_mutex_lock"'  | awk -F' ' '{print $2}'
#
#  the output is : 000000000000bfc0
#  3- add bothe above address to compute the virtual address for function pthread_mutex_lock 
#   the result is : 7f1901354000 + 000000000000bfc0 = 7F190135FFC0
#  

# extract the virtual base address for the libpthread which is dynamically loaded.
cat maps.dump | grep -m 1 libpthread | awk -F'-' '{print $1}' > $tmpfile
pthread_baseaddr="0x"$(head -n 1 $tmpfile)

# extract the full path name for the pthread library
cat maps.dump | grep -m 1 libpthread | awk -F' ' '{print $6}' > $tmpfile
pthread_pathname=$(head -n 1 $tmpfile)

# extract the virtual address of function pthread_mutex_lock
readelf -s $pthread_pathname | awk -F' ' '$8=="pthread_mutex_lock"' | awk -F' ' '{print $2}' > $tmpfile
offset_addr="0x"$(head -n 1 $tmpfile)
virtual_addr=$((pthread_baseaddr + offset_addr))
printf "The virtual address for function pthread_mutex_lock is 0x%X\n" $virtual_addr

# extract the virtual address of function pthread_mutex_unlock
readelf -s $pthread_pathname | awk -F' ' '$8=="pthread_mutex_unlock"' | awk -F' ' '{print $2}' > $tmpfile
offset_addr="0x"$(head -n 1 $tmpfile)
virtual_addr=$((pthread_baseaddr + offset_addr))
printf "The virtual address for function pthread_mutex_unlock is 0x%X\n" $virtual_addr



# All global variables of the running process are computed as follows


# Extract the virtual base address for the running process itself.
# This is the base address for the gloabal variables.
# other parts, to do later
head -n 1 maps.dump | awk -F'-' '{print $1}' > $tmpfile
prog_baseaddr="0x"$(head -n 1 $tmpfile)

# extract the virtual address of a given global variables
# 1 - 'count' global variable
readelf -s $prog | awk -F' ' '$8=="count"' | awk -F' ' '{print $2}' > $tmpfile
offset_addr="0x"$(head -n 1 $tmpfile)
virtual_addr=$((prog_baseaddr + offset_addr))
printf "The virtual address for variable count is 0x%X\n" $virtual_addr

# 2 - 'mutex' global variable
readelf -s $prog | awk -F' ' '$8=="mutex"' | awk -F' ' '{print $2}' > $tmpfile
offset_addr="0x"$(head -n 1 $tmpfile)
virtual_addr=$((prog_baseaddr + offset_addr))
printf "The virtual address for variable mutex is 0x%X\n" $virtual_addr

