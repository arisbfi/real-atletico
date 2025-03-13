#!/bin/bash

tmux send-keys "rlss" C-m

tmux split-window -h
sleep 5
tmux send-keys "rlgs" C-m
tmux split-window -v
tmux send-keys "rlbofe" C-m
tmux split-window -h
tmux send-keys "rlts" C-m
tmux split-window -v
tmux send-keys "rlndfw" C-m
tmux split-window -h
tmux send-keys "rlndftw" C-m

tmux select-layout tiled
tmux rename-window "lora-services"
