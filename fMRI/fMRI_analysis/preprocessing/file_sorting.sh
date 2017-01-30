#!/bin/bash
# simple script to sort files from the scanner into subject folders for further processing

echo "enter home directory (must contatin a folder ""raw"" with raw data from the scanner):"
read homedir

source_path=$homedir/raw
destination_path=$homedir/sub_data

echo "enter number of subjects (subjects must be sorted continuously from 1 to n):"
read subnum

echo " "
echo "source path is:"
echo $source_path
echo "destionation path is:"
echo $destination_path
echo " "
echo "this will create file structure compatible with analysis scripts in destination"
echo " "
read -p "press enter to continue..."

for sub in $(seq -f "%03g" 1 $subnum)
do

	echo " "
	echo " "
	echo "subject: "$sub""
	echo " "

	echo " "
	echo "functional runs:"
	ls $source_path/*/SNS_AMBI_"$sub"_*/*fmri*.nii
	echo "will be copied to:"
	echo $destination_path/$sub/mr_data

	echo " "
	echo "structural image:"
	ls $source_path/*/SNS_AMBI_"$sub"_*/*t1*.nii
	echo "will be copied to:"
	echo $destination_path/$sub/mr_data
	
	echo " "
	echo "B0 maps:"
	ls $source_path/*/SNS_AMBI_"$sub"_*/*b0*.nii
	echo "will be copied to:"
	echo $destination_path/$sub/mr_data/b0

	echo " "
	echo "physio files:"
	ls $source_path/*/SNS_AMBI_"$sub"_*/SCANPHYSLOG*.log
	echo "will be copied to:"	
	echo $destination_path/$sub/mr_data/physio
		

done

echo " "
echo " "
read -p "check above information for accuracy and press enter to continue..."

for sub in $(seq -f "%03g" 1 $subnum)
do

	echo " "
	echo " "
	echo "subject: "$sub""
	echo " "

	echo "functional runs:"
	mkdir -vp $destination_path/$sub/mr_data
	cp -v $source_path/*/SNS_AMBI_"$sub"_*/*fmri*.nii $destination_path/$sub/mr_data

	echo "structural image:"
	cp -v $source_path/*/SNS_AMBI_"$sub"_*/*t1*.nii $destination_path/$sub/mr_data
	
	echo "B0 maps:"
	mkdir -v $destination_path/$sub/mr_data/b0
	cp -v $source_path/*/SNS_AMBI_"$sub"_*/*b0*.nii $destination_path/$sub/mr_data/b0

	echo "physio files:"
	mkdir -v $destination_path/$sub/mr_data/physio
	cp -v $source_path/*/SNS_AMBI_"$sub"_*/SCANPHYSLOG*.log $destination_path/$sub/mr_data/physio

done

echo " "
read -p "thank you, finished... press enter to quit."
