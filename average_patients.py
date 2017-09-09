import csv
file_str="uci_second.csv"
f = open(file_str,'rb')
feature_reader = csv.reader(f,delimiter=',')

to_exclude_attributes=[3,4,5]
class_row=5
feature_reader.next()
num_patients=42
num_attributes=22
header = [None]*(22-len(to_exclude_attributes)+1)
for i in range(len(header)):
	header[i]="col" + str(i)
num_repeats=[0] * num_patients
write_array=[None] * num_patients
for i in range(num_patients):
	write_array[i]=[0] * (num_attributes+1)

for feature_line in feature_reader:
	num_repeats[int(feature_line[0])-1]+=1
	for i in range(len(feature_line)):
		#print i
		if i not in to_exclude_attributes:
			#print "write[0]: ",len(write_array[i])
			#print "feature: ", len(feature_line)
			write_array[int(feature_line[0])-1][i] += float(feature_line[i])
	write_array[int(feature_line[0])-1][-1]+=float(feature_line[class_row])




f_write = open("cleaned_uci_second.csv",'w')
feature_writer = csv.writer(f_write,delimiter=',')
feature_writer.writerow(header)
print len(write_array)
for i in range(len(write_array)):
	print write_array[i][2]
	#print write_array[i][-1]
	write_array[i] = write_array[i][:3] + write_array[i][5+1 :]
	for j in range(len(write_array[i])):
		write_array[i][j] = write_array[i][j]/(num_repeats[i]+0.0)
	if write_array[i][-1]>20:
		write_array[i][-1]="+"
	else:
		write_array[i][-1]="-"

	if write_array[i][2]==0:
		write_array[i][2] = "m"
	else:
		write_array[i][2] = 'f'
	feature_writer.writerow(write_array[i])