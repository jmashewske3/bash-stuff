#!/bin/bash -u

THREAD_FS=/tmp/threads
THREAD_SLEEP=1s
THREAD_RUNNING=running
THREAD_STOPPED=stopped

function init() {
    rm -rf $THREAD_FS
    mkdir -p $THREAD_FS
}

## count-files
# count-files {dir :- ./}
# gives the number of files in a directory, or $PWD if one 
#+ isn't passed.  I'll do this the right way later.
function count-files() (
    local dir
    dir=${1:-.}
    ls $dir | wc -l
)

## spawn-thread
# spawn-thread poolname fun {args $@}
# Adds a thread to the pool referenced by poolname
#+ and calls fun with args as arguments.  Creates a file in
#+ $THREAD_FS/$poolname/$ind, which is removed after the function
#+ ends.
function spawn-thread() {
    local poolname fun args ind dir file
    poolname=$1; shift
    fun=$1; shift
    args="$@"
    dir=$THREAD_FS/$poolname
    mkdir -p $dir
    ind=$(count-files $dir)
    file=$dir/$ind
    >$file
    { $fun $args; rm $file; } &
}

## join-pool
# join-pool poolname
# Ensures every thread in the given pool is complete before the
#+ function returns
function join-pool() {
    local poolname dir 
    poolname=$1
    dir=$THREAD_FS/$poolname
    while [[ $(count-files $dir) != 0 ]]; do
	count-files $dir
	sleep $THREAD_SLEEP
    done
    rm -r $dir
}

