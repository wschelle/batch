#!/bin/bash

module load anaconda3
source activate venv1

python3 /home/control/wousch/Pilot/Pilot002/derivatives/scripts/kalmanfilter_multiprocessing.py

