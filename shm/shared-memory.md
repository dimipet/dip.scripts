shm = shared memory = mem that two or more processes can access
one process shares, the others access it to speed up

# list processes
```
$ ipcs -m
------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status      
0x00000000 264146     dimipet    600        157760     2          dest         
```
# get info
use `shmid` (shared mem id) to get info
```
$ ipcs -m -i 264146

Shared memory Segment shmid=262144
uid=....	gid=....	cuid=....	cgid=....
mode=....	access_perms=....
bytes=......	lpid=......	cpid=....	nattch=..
att_time=...  
det_time=...  
change_time=...
```
# processes
lists processes that use shm segment
```
$ pstree -p 262146
```

