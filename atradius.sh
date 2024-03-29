#!/bin/bash
#
# Setup a work space called `atradius`
#
# * Window 1 is set to the local puppetserver
# * Window 2 is set to the modules dir
# * Window 3 is set to the profiles dir
# * Window 4 is set to the puppet hiera dir
# * Window 5 has 2 vertical panes:
# ** pane 1: ims-db-0
# ** pane 2: ims-db-1
# * Window 6 has 3 panes
# ** pulp
# ** metrics: grafana, prometheus
# ** nginx proxy
# note: `atrcl` aliased to `cd ~/path/to/work`
#
session="Atradius"

# Set up tmux, start server
if [[ -n $(pgrep tmux) ]]; then
    echo "tmux server already running..."
else
    tmux start
fi

# Check if tmux already has session $session
tmux has-session -t $session
if [ $? != 0 ]
then
    # Create a new tmux session
    tmux new-session -d -s $session
    
    ## Window 1: PUPPETMASTER
    tmux renamew "puppetmaster"
    # Start puppetserver
    tmux send-keys -t $session:1.1 "atrcl;vagrant up puppet-0" C-m 
    
    ## Window 2: MODULES
    tmux new-window -t $session:2 -n "modules"
    tmux send-keys -t $session:2.1 "atrcl;cd ifrs17-puppet-modules;clear;ls -ltr" C-m

    ## Window 3: PROFILES
    tmux new-window -t $session:3 -n "profiles"
    tmux send-keys -t $session:3.1 "atrcl;cd ifrs17-puppet-modules/profiles;clear;ls -ltr" C-m
    
    ## Window 4: HIERA
    tmux new-window -t $session:4 -n ifrs17-puppet-hiera
    tmux send-keys -t $session:4.1 "atrcl;cd ifrs17-puppet-hiera-tree;clear;ls -ltr" C-m
    
    ## Window 5: DB
    # Create a new window called DB
    tmux new-window -t $session:5 -n DB
    tmux splitw -h -t $session:5
    
    # Select pane 1, start ims-db-0
    tmux send-keys -t $session:5.1 "atrcl;vagrant up ims-db-0" C-m
    # Select pane 2, start ims-db-1
    tmux send-keys -t $session:5.2 "atrcl;vagrant up ims-db-1" C-m
    
    ## Window 6: APPS pulp, monitoring
    # Create a new window called Monitoring
    tmux new-window -t $session:6 -n Monitoring 
    tmux splitw -v -t $session:6
    tmux splitw -v -t $session:6.2
    tmux selectl -E -t $session:6
    
    tmux send-keys -t $session:6.1 "atrcl;vagrant up ims-repo-0" C-m
    tmux send-keys -t $session:6.2 "atrcl;vagrant up ims-metrics-0" C-m
    tmux send-keys -t $session:6.3 "atrcl;vagrant up ims-website-0" C-m
    
    ## return to main window
    tmux select-window -t $session:1
fi
    
## Finished setup, attach to the tmux session!
tmux attach-session -t $session
    
