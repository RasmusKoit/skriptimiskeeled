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

if [ ! -f ./rrdtoolbase.rrd ]; then
	rrdtool create rrdtoolbase.rrd \
	--start 1520953961 \
	--step 600 \
	DS:started:GAUGE:900:1:9999999 \
	DS:lasted:GAUGE:900:1:9999999 \
	RRA:MAX:0.5:1:27260
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
        printf "%d:%d\n" "$epochFailure" "$epochLength" >> ./rrdtool.txt

	# rrdtool update rrdtoolbase.rrd --template ts:lasted $epochFailure:$epochLength:
	rrdtool update rrdtoolbase.rrd $epochFailure:$epochFailure:$epochLength
        
        
        IFS=$'\n'
        
        unset failuretime
        unset failed
        unset hours minutes seconds
    fi
done

rrdtool graph latency_graph.png \
-w 785 -h 120 -a PNG \
--slope-mode \
--start -86400 --end now \
--font DEFAULT:7: \
--title "ping default gateway" \
--watermark "`date`" \
--vertical-label "latency(ms)" \
--right-axis-label "latency(ms)" \
--lower-limit 0 \
--right-axis 1:0 \
--x-grid MINUTE:10:HOUR:1:MINUTE:120:0:%R \
--alt-y-grid --rigid \
DEF:started=rrdtoolbase.rrd:started:MAX \
DEF:lasted=rrdtoolbase.rrd:lasted:MAX \
LINE1:lasted#0000FF:"lasted(epoch s)" \
	
# Update data set

