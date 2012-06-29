#!/bin/bash
# simple shell script to run R to create dat.json file

R CMD BATCH --no-save make_json_file.R Rout.txt
