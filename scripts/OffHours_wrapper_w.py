import subprocess
import time
import datetime
# grab some subjs as list
my_file = open("/cbica/projects/abcdfnets/clean100.txt", "r")
content = my_file.read()
content_list = content. split("\n")
# remove last line (blank)
content_list.pop()
# feed em' in as subjects
subjects = content_list
# only first(last) 1048 ran?
# anddd it died after another 2630 subjs. 2071 left to run.
# and it died again (9/24/21). 1833 left to run
#subjects = subjects[0:1833]
# while there are more than 0 subjects left to run
while len(subjects)>0:
  # grab qsub info, get number of jobs being run
  qstat = subprocess.check_output(['qstat'],shell=True).decode().split('/bin/python')[0]
  que = len(qstat.split('\n'))-3
  # if we are using less than 5 job slots (one is occupied by this script)
  if que < 8:
    # see if it is the weekend, 0, 1, 2, 3, and 4 are weekday, 5 and 6 are weekend
    weekno = datetime.datetime.today().weekday()
    # see if it is before 9 or after 5 
    Hour = time.localtime().tm_hour 
    # if weekend OR after 6 PM OR before 9 AM
    if weekno > 4 or Hour < 9 or Hour > 16 :
      newsub = subjects.pop()
      # submit job (if above conditions are met)
      subprocess.run(["qsub","-l","h_vmem=15G,s_vmem=14G","qsubMatlab_w.sh",newsub])
      time.sleep(60) #wait a minute
    # added this to run 3 subjs (1 slot for this job) during ON hours
    elif que < 4:
      newsub = subjects.pop()
      subprocess.run(["qsub","-l","h_vmem=15G,s_vmem=14G","qsubMatlab_w.sh",newsub])
      time.sleep(60) #wait a minute
