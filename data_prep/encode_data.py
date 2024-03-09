import pandas as pd 
import numpy as np

#Sunday:1, Monday:2, Tuesday:3, Wednessday:4, Thursday:5, Friday:6, Saturday:7
#electric: 0, classic: 1
#causal: 0, member: 1
#Winter: 0, Spring, 1, SUmmer, 2, Fall, 3
#Months go 1-12

def extract_day(date):
    if date.split('-')[2][0] == '0':
        return date.split('-')[2][1]
    return date.split('-')[2]

def main():
    df = pd.read_csv('..\\data\\3_9_Data\\traindata.csv')
    #df = pd.DataFrame({'day_of_week':['Monday', 'Friday'], 'rideable_type':['classic_bike', 'electric_bike']})
    day_dict = {'Sunday': 0, 'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4, 'Friday': 5, 'Saturday': 6}
    df['day_of_week'] = df['day_of_week'].map(day_dict)
    bike_dict = {'electric_bike': 0, 'classic_bike': 1}
    df['rideable_type'] = df['rideable_type'].map(bike_dict)

    print('Finish day of week and bike type')

    member_dict = {'casual': 0, 'member': 1}
    df['member_casual'] = df['member_casual'].map(member_dict)
    month_dict = {'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6,
                  'July': 7, 'August': 8, 'September': 9, 'October': 10, 
                  'November': 11, 'December': 12}
    
    print('Finish member type and month')

    df['month'] = df['month'].map(month_dict)
    season_dict = {'Winter': 0, 'Spring': 1, 'Summer': 2, 'Fall': 3}
    df['season'] = df['season'].map(season_dict)
    df['date'] = df['date'].apply(extract_day)

    df.to_csv('encoded_dataset.csv', index=False)
main()
