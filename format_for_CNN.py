import os
import csv

data_dir="PWP_accel"
output_name="output.txt"
output_file = open(output_name,'w')
output_writer = csv.writer(output_file,delimiter=',')
for filename in os.listdir(data_dir):
	file_info = filename.split('_')
	file_id = file_info[0]+"_"+file_info[2].replace(".txt","")
	file_class = file_info[1]
	trial_filename=os.path.join(data_dir,filename)
	trial_file=open(trial_filename,'r')
	trial_reader = csv.reader(trial_file,delimiter=',')
	for trial_row in trial_reader:
		write_row=trial_row
		write_row.insert(0,file_id)
		write_row.insert(1,file_class)
		output_writer.writerow(write_row)
