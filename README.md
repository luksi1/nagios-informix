# nagios-informix
Nagios / OP5 plugin to monitor Informix databases

Description
======
Monitor the following states of an Informix database:

- Chunks
- Logs
- Waits
- Status

Dependencies
======
- Perl
- DBD-Informix
- Perl's core modules
- utils 

Examples
======
```Examples
check_ids --mode chunks--warning 90 --critical 95
check_ids --mode logs --warning 25 --critical 50
check_ids --mode status
check_ids --mode waits -w 10 -c 20
```

Notes
======
- You will need to compile DBD-Informix for this plugin to work.
- You will need to add authentication(username/password), path to INFORMIXDIR and path to INFORMIXSERVER for each perl script. Also don't forget to alter the shbang line so that it points at your Perl installation.

Bugs
======
- If you use a seperate temp dbspace, this may fill up, which is normal. If you want to exclude this dbspace from the chunks monitor, you will need to alter the function "checkChunks". 

Author
======
Luke Simmons (VGR IT)

Version
======
1.0
