import pandas as pd 
import numpy as np
from datetime import datetime

def extract_date(ended_timeframe):
    return ended_timeframe.split()[0]

def extract_day_of_week(ended_timeframe):
    date = extract_date(ended_timeframe)
    # Parse the input date string
    date_obj = datetime.strptime(date, "%m/%d/%Y")
    # Format the date object into "Year-Month-Day" format
    formatted_date = date_obj.strftime("%Y-%m-%d")
    d = pd.Timestamp(formatted_date)
    return d.day_name()

def extract_month(ended_timeframe):
    date = extract_date(ended_timeframe)
    # Parse the input date string
    date_obj = datetime.strptime(date, "%m/%d/%Y")
    # Get the month name from the date object
    month_name = date_obj.strftime("%B")
    return month_name

def main():
    df = pd.read_csv( 'C:\\Users\\Amber\\Desktop\\Coding\\cleandata.csv')
    df['date'] = df['ended_at'].apply(extract_date)
    print('1')
    df['day_of_week'] = df['ended_at'].apply(extract_day_of_week)
    print('2')
    df['month'] = df['ended_at'].apply(extract_month)
    df.to_csv('clean_data_v2.csv')
    print('3')

main()