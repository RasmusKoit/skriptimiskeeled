#!/bin/bash

IFS=$'\n'


sed -i '/apcupsd/d' ./tekst.txt
sed -i '/battery/d' ./tekst.txt
sed -i '/batteries/d' ./tekst.txt
sed -i '/directive/d' ./tekst.txt
sed -i '/PANIC/d' ./tekst.txt
sed -i '/UPS Self Test/d' ./tekst.txt
sed -i 's/Power failure./failure/g' ./tekst.txt
sed -i 's/Power is back. UPS running on mains./restored/g' ./tekst.txt

rm -f parsedFile.txt
rm -f rrdtool.txt
rm -f rrdtool.data
rm -f apcupsd.rrd

if [ ! -f ./apcupsd.rrd ]; then
#	rrdtool create rrdtoolbase.rrd \
#	--start 1520953961 \
#	--step 600 \
#	DS:started:GAUGE:900:1:9999999 \
#	DS:lasted:GAUGE:900:1:9999999 \
#	RRA:MAX:0.5:1:27260
	rrdtool create apcupsd.rrd \
	--step 200 \
	--start 1520953961  \
	DS:powerfail:GAUGE:200:0:U \
	RRA:MAX:0.5:1:104000 \

fi

for i in $(cat ./tekst.txt); do
    status=$(echo $i | awk '{print $4}')
    
    if [[ "$status" == *"failure"* && "$failed" != 'true' ]]; then
        failuretime="$(echo $i | awk '{print $2}')"
        failed=true
    fi
    
    if [[ "$status" == *"restored"* ]]; then
        #                echo "$(echo $i | awk '{print $1}')"
        #                echo -n "$failuretime "
        #echo "$(echo $i | awk '{print $4}')"
        restoretime="$(echo $i | awk '{print $2}')"
        savingmode="$(echo $i | awk '{print $3}')"
        #                echo -n "$restoretime "
        IFS=$':'
        
        hours="$(echo $(echo $restoretime | awk '{print $1}') - $(echo $failuretime | awk '{print $1}')|bc)"
        #                echo -n $hours':'
        minutes="$(echo $(echo $restoretime | awk '{print $2}') - $(echo $failuretime | awk '{print $2}')|bc)"
        #                echo -n $minutes':'
        seconds="$(echo $(echo $restoretime | awk '{print $3}') - $(echo $failuretime | awk '{print $3}')|bc)"
        #                echo "$seconds until restore was established"
        
        if [ "$seconds" -lt 0 ]; then
            seconds=$((seconds + 60))
            minutes=$((minutes - 1))
        fi
        
        if [ "$minutes" -lt 0 ]; then
            minutes=$((minutes + 60))
            hours=$((hours - 1))
        fi
        
        if [ "$hours" -lt 0 ]; then
            hours=$((hours + 24))
            days=$((days - 1))
        fi
        restoredate="$(echo $i | awk '{print $1}')"
        # date +%s -d "2018-03-22 11:12:35 +0200"
        #1520953961
        #1520953976
        epochFailure=`date +%s -d "$restoredate $failuretime $savingmode"`
        #echo "$epochFailure"
        epochRestore=`date +%s -d "$restoredate $restoretime $savingmode"`
        #echo "$epochRestore"
        epochLength=`echo "$epochRestore - $epochFailure" | bc`
        printf "%s %s %s - %s was a failure which lasted for %02d:%02d:%02d\n" "$restoredate" "$failuretime" "$savingmode" "$restoretime" "$hours" "$minutes" "$seconds" >> ./parsedFile.txt
        if [ "$epochLength" -lt 0 ]; then
            epochLength=`echo $epochLength | tr -d -`
        fi
        printf "%d:%d\n" "$epochFailure" "$epochLength" >> ./rrdtool.txt

	# rrdtool update rrdtoolbase.rrd --template ts:lasted $epochFailure:$epochLength:
#	rrdtool update rrdtoolbase.rrd $epochFailure:$epochFailure:$epochLength
        
        
        IFS=$'\n'
        
        unset failuretime
        unset failed
        unset hours minutes seconds
    fi
done


# Update data set
echo "siin olen"




# fillGap 1533729713 1533732623 200 2910
lineN=0
unset IFS
step=200
mapfile -t arr < rrdtool.txt
for ((lineN=0; lineN<${#arr[*]}; lineN=lineN+1)); do
    line1=${arr[lineN]}
    line2=${arr[lineN+1]}

    IFS=':'
    timestamp_one=`echo $line1 | awk '{print $1}'`
    duration_one=`echo $line1 | awk '{print $2}'`

    timestamp_two=`echo $line2 | awk '{print $1}'`
    duration_two=`echo $line2 | awk '{print $2}'`
    # echo $timestamp $duration

    # echo $timestamp_one $duration_one : $timestamp_two $duration_two

    echo $timestamp_one:$duration_one >> rrdtool.data




    if [ $duration_one -gt $step ]; then
        newDuration=$(( ${timestamp_one} + ${duration_one} ))
        echo $newDuration:0 >> rrdtool.data
    else
        for ((i=${timestamp_one} + step; i<timestamp_two; i=i+step)); do
            newtimestamp=$((i))
            echo $newtimestamp:0 >> rrdtool.data
        done
    fi
done

# for entry in $(cat ./rrdtool.txt); do
#     IFS=':'
#     while IFS= read -r line;
#     do
#         timestamp=`echo $line | awk '{print $1}'`
#         duration=`echo $line | awk '{print $2}'`
#         # echo $timestamp $duration

#         if [ $lineN == 0 ]; then
#             echo $timestamp:$duration >> rrdtool.data
            
#         fi
#         echo $timestamp:$duration >> rrdtool.data

#         if [ $duration -gt $step ]; then
#             newStep=0
#             for ((i=step; i<duration; i=i+step)); do
#                 newStep=i
#             done
#             newtimestamp=$(( timestamp + newStep ))
#             echo $newtimestamp:0 >> rrdtool.data

#         else
#             newtimestamp=$(( timestamp + step))
#             echo $newtimestamp:0 >> rrdtool.data
#         fi
        
#         lineN=$(( lineN + 1 ))
#     done <<< `echo $entry`
# done

IFS=$'\n'


for i in $(cat ./rrdtool.data); do
    # echo $i
    rrdtool update apcupsd.rrd -t powerfail $i
done


rrdtool graph powerfails_1y.png \
-w 1080 -h 768 -a PNG \
--slope-mode \
--start now-1y --end now \
--font DEFAULT:7: \
--title "Powerfails 1 year" \
--watermark "`date`" \
--vertical-label "failure (s)" \
--lower-limit 0 \
--x-grid MINUTE:10:HOUR:1:MINUTE:120:0:%R \
--alt-y-grid --rigid \
--lower-limit 0.5 -o \
DEF:powerfail=apcupsd.rrd:powerfail:MAX \
LINE1:powerfail#0000FF:"Powerfails (s)" \

echo "mida mis ending on?"


