from datetime import datetime
from datetime import time

import csv
csvHeader = ['Date', 'Duration', 'Label']

d1 = datetime.now()
d2 = datetime.now()
dur = 0

filePath = 'tekst.txt'

try:
    with open(filePath) as f, open('powerOutage.csv', 'w') as csvFile:
        writer = csv.DictWriter(csvFile, fieldnames=csvHeader)
        writer.writeheader()

        line = f.readline()
        while line:
            if (line.__contains__('failure')):
                x_time = datetime.strptime((" ".join(line.split()[:3])), '%Y-%m-%d %H:%M:%S %z')
                d1 = x_time.timestamp()
            line = f.readline()

            if(line.__contains__('restored')):
                y_time = datetime.strptime((" ".join(line.split()[:3])), '%Y-%m-%d %H:%M:%S %z')
                d2 = y_time.timestamp()
                dateLabel = " ".join(line.split()[:3])
                dur = int(abs(d2-d1))

                writer.writerow({'Date': int(d1), 'Duration': dur, 'Label': str(dateLabel)})


except:
    print("Something went wrong with the file!")