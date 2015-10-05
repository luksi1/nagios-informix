# nagios-informix
Nagios / OP5 plugin to monitor Informix databases

Description
======

Monitor the following states of an Informix database:

- Chunks
- Logs
- Waits
- Status

This plugin uses a Perl class, with which each Perl script utilizes. Feel free to add additional methods as you see fit. 

Dependencies
======
- Perl
- DBD-Informix

Examples
======
```Examples
check_ids_chunks --warning 90 --critical 95
check_ids_logs --warning 25 --critical 50
check_ids_status -w 1 -c 1
check_ids_waits -w 10 -c 20
```

Notes
======
- You will need to compile DBD-Informix for this plugin to work.
- You will need to add authentication(username/password), path to INFORMIXDIR and path to INFORMIXSERVER for each perl script. 
- You will need to place Informix.pm in "/opt/informix/scripts" or change the path of "use lib" in each script.

Author
======
Luke Simmons (VGR IT)

Version
======
1.0
