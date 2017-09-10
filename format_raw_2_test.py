import csv



raw_name = "RawAccelerometerData.txt"
raw_file = open(raw_name,'r')
write_file  = open("newpatient.csv",'w')
raw_reader= csv.reader(raw_file,delimiter=',')
write_writer = csv.writer(write_file,delimiter=',')

raw_array=list(raw_reader)
#print raw_array
skipby=len(raw_array)/53
counter=0
count_write=0
for line in raw_array:
		i = line
		i.insert(0,5)
		i.insert(0,"new_patient")
		write_writer.writerow(i)