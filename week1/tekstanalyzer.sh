#!/bin/bash

# Vahetada välja bataka tekstid
# Lisada juurde iga päeva kohta 0 info, kui sündmust pole
# Näidata kui pikalt sündmus maas oli
# Teen asju

sed -i '/apcupsd/d' ./tekst.txt
sed -i '/battery/d' ./tekst.txt
sed -i '/batteries/d' ./tekst.txt
sed -i '/directive/d' ./tekst.txt
sed -i '/PANIC/d' ./tekst.txt
sed -i '/UPS Self Test/d' ./tekst.txt
sed -i 's/Power failure./failure/g' ./tekst.txt
sed -i 's/Power is back. UPS running on mains./restored/g' ./tekst.txt
