#start py file
import os
from datetime import date, timedelta, datetime

SdDate = '2018-07-07'
EdDate = '2018-07-11'
project_id = 'bvin-188812'

Start_date = date(int(SdDate.split('-')[0]), int(SdDate.split('-')[1]), int(SdDate.split('-')[2]))
End_date = date(int(EdDate.split('-')[0]), int(EdDate.split('-')[1]), int(EdDate.split('-')[2]))

Number_days = abs((Start_date - End_date).days)
dDate = SdDate
Iterating_day = Start_date
dDate2 = Iterating_day.strftime("%Y%m%d")


for table in ['users_list_date']:
    n = 0
    while n <= int(Number_days):
        print Iterating_day
        query = 'SELECT \'' + dDate +  '\' as date, primaryEmail, creationTime, ' \
        'emails.primary, emails.address, lastLoginTime, customerId, orgUnitPath FROM [' + project_id + ':raw_data.users_list_date] ' \
        'WHERE _PARTITIONTIME = TIMESTAMP (\'2018-07-12\')'
        os.system ('bq query --noflatten_results --allow_large_results --destination_table=' + project_id + ':raw_data.' + table + '\$' + dDate2 + ' \"' + query + '\"')
        Iterating_day = Iterating_day + timedelta(days=1)
        dDate = Iterating_day.strftime("%Y-%m-%d")
        dDate2 = Iterating_day.strftime("%Y%m%d")
        n += 1
#End py file
