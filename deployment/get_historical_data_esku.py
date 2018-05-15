import os
from datetime import date, timedelta
import time

SdDate = '2018-03-20'
EdDate = '2018-03-22'
project_id = 'YOUR_PROJECT_ID'

Start_date = date(int(SdDate.split('-')[0]), int(SdDate.split('-')[1]), int(SdDate.split('-')[2]))
End_date = date(int(EdDate.split('-')[0]), int(EdDate.split('-')[1]), int(EdDate.split('-')[2]))

Number_days = abs((Start_date - End_date).days)
dDate = SdDate
Iterating_day = Start_date
formatted_date = Iterating_day.strftime("%Y-%m-%d")

n = 0
while n <= int(Number_days):
    print Iterating_day

    print "\n"
    print "=========================== LEVEL 1 ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=update&level=1&dateref=' + formatted_date + '"')
    time.sleep(60)

    print "\n"
    print "=========================== LEVEL 2 ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=update&level=2&dateref=' + formatted_date + '"')
    time.sleep(120)

    print "\n"
    print "=========================== LEVEL 3 ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=update&level=3&dateref=' + formatted_date + '"')
    time.sleep(60)

    print "\n"
    print "=========================== LEVEL 4 ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=update&level=4&dateref=' + formatted_date + '"')
    time.sleep(60)

    print "\n"
    print "=========================== LEVEL 5 ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=update&level=5&dateref=' + formatted_date + '"')
    time.sleep(60)

    print "\n"
    print "=========================== LEVEL 6 ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=update&level=6&dateref=' + formatted_date + '"')
    time.sleep(10)

    print "\n"
    print "=========================== LEVEL 7 ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=update&level=7&dateref=' + formatted_date + '"')
    time.sleep(10)

    print "\n"
    print "=========================== CUSTOM LEVEL  ============================="
    os.system(
        'curl -XGET "https://' + project_id + '.appspot.com/bq_api?op=custom_update&level=1&dateref='
        + formatted_date + '"')
    time.sleep(30)

    Iterating_day = Iterating_day + timedelta(days=1)
    dDate = Iterating_day.strftime("%Y-%m-%d")
    formatted_date = Iterating_day.strftime("%Y-%m-%d")
    n += 1
