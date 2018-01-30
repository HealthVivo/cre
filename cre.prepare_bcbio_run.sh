#!/bin/bash

# prepares family for bcbio run when input files are family_sample.bam or family_sample_1/2.fq.gz
family=$1

#$2 = template type, no value - default WES, noalign - no alignment (for rerunning), fast - no realignment,recalibration, and only gatk
template_type=$2
echo $template_type

cd $family

cp ~/cre/bcbio.sample_sheet_header.csv $family.csv

cd input

#there should be no other files except input fq.gz or bams in the input dir
ls | sed s/.bam// | sed s/.bai// | sed s/"_1.fq.gz"// | sed s/"_2.fq.gz"// | sort | uniq > ../samples.txt

cd ..

while read sample
do
    echo $sample","$sample","$family",,," >> $family.csv
done < samples.txt

#default template
template=~/cre/cre.bcbio.templates.wes.yaml

if [ -n "$2" ]
then
    if [ $template_type == "noalign" ]
    then
	template=~/cre/cre.bcbio.templates.wes.noalign.yaml
    elif [ $template_type == "fast" ]
    then
	echo fast
	template=~/cre/cre.bcbio.templates.wes.fast.yaml
    fi
fi

bcbio_nextgen.py -w template $template $family.csv input/*

mv $family/config .
mv $family/work .
rm $family.csv
rmdir $family

cd ..
