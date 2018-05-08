import os
from datetime import date, timedelta, datetime

SdDate = '2018-01-20'
EdDate = '2018-01-21'
project_id = 'YOUR_PROJECT_ID'

Start_date = date(int(SdDate.split('-')[0]), int(SdDate.split('-')[1]), int(SdDate.split('-')[2]))
End_date = date(int(EdDate.split('-')[0]), int(EdDate.split('-')[1]), int(EdDate.split('-')[2]))

Number_days = abs((Start_date - End_date).days)
dDate = SdDate
Iterating_day = Start_date
dDate2 = Iterating_day.strftime("%Y%m%d")

n = 0
while n <= int(Number_days):
    print Iterating_day
    with open('tables_list.txt') as f:
        for table in f:
            print project_id + ':' + table.strip() + '\$' + dDate2
            os.system('bq rm -f -t ' + project_id + ':' + table.strip() + '\$' + dDate2)

    Iterating_day = Iterating_day + timedelta(days=1)
    dDate = Iterating_day.strftime("%Y-%m-%d")
    dDate2 = Iterating_day.strftime("%Y%m%d")
    n += 1
