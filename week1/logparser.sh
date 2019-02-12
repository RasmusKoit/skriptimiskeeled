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
        
        
        
        IFS=$'\n'
        
        unset failuretime
        unset failed
        unset hours minutes seconds
    fi
done



