## Univariate Analysis 

The univariate analysis was done using Tableau. 

![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/e25211bc-0918-4580-8e4b-1a7b23eb9606)
![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/ace6c515-9175-43cc-874a-b7a355063967)

A majority of bike rides were locked at e-station/public rack. Since these do not necessarily correspond to one location (based on coordinates recorded) these were excluded from our analysis. 

<img src="https://github.com/nshah-11/divvy-bikesharing/assets/97864887/6abcfe68-ba31-4484-9575-fa93ed9c061e" width=30% height=30%>

<img src="https://github.com/nshah-11/divvy-bikesharing/assets/97864887/91187ede-8d07-4fac-958c-ff4bbb65fa80" width=60% height=50%>

![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/c57fd279-bcfd-4622-b844-9cecb141c4a3)

Most bike rides are during the summer with the least during winter. It appears there may be a seasonal trend as well. 

<img src="https://github.com/nshah-11/divvy-bikesharing/assets/97864887/cbf17641-2b09-4970-9ea4-562c4917d53a" width=50% height=50%>

There is approximately an even distribution of bike rides throughout the days of the week with Sundays and Mondays having the lowest amount of bike rides. 

![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/7a2ec17b-f4f9-4c8f-844b-f6240e17c80d)

Most bike rides have a trip duration of 5 mins. The average trip duration is 14.5 minutes. The minimum trip duration was 2 minutes with a maximum of 179 mins. Even after removing trips that are less than 1 minute and greater than 180 mintues, it appears there are still some outliers. But for our analysis, they will not be removed. 

<img src="https://github.com/nshah-11/divvy-bikesharing/assets/97864887/008790dc-3845-4865-ae84-9d2fdbdf1502" width=45% height=50%>
<img src="https://github.com/nshah-11/divvy-bikesharing/assets/97864887/6088e282-fcc8-4548-9a30-a65aca0f3d77" width=45% height=50%>

Most rides start and end at during 5PM. The lowest amount of rides taken are during the early morning hours (1am to 5am).

<img src="https://github.com/nshah-11/divvy-bikesharing/assets/97864887/ea8341a5-c236-40d0-b97d-2934ed702bbb" width=40% height=40%>
<img src="https://github.com/nshah-11/divvy-bikesharing/assets/97864887/b7424af7-559b-421f-847a-bc4d4fb226a0" width=30% height=30%>

Approximately 50% of riders use electric bikes and 50% use classic bikes. Approximately 2/3 of riders are members.  

## Bivariate Analysis

Bivariate Analysis was done using both Tableau and R. 

![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/524fde39-7aa1-44b0-ac0d-8faad49a478d)

It appears there is an approximately even split between classic and electric bikes, where a majority of bike riders are members vs casual.Specifically approximately 2/3 of riders are members and 1/3 of the population are casual riders.

![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/786bbeaa-0a4d-4d68-91c1-ed36634925b3)
![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/848987c2-e767-4ab3-888b-a6138756a9ea)

1.Looks like thre are more casual riders on the weekends compared to weekdays. 2. There are more casual riders during the summer in contrast to members during their respective seasons. 3. Overall, January, February, March and December have less than 200,000 riders compared to other months. Specifically there is at least 1/2 of casual riders during April through October, compared to members.

![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/dbdf8349-8ba8-425a-8f77-6f1ab0a02893)
![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/2b0b5284-4bf7-4486-b02c-c48fcecd8d30)

As mentioned previously, there are outliers for duration.It looks like after 37 minutes there are more casual riders than members.This could be because members may be using bikesharing for commuting vs casual riders who may have more time to explore and ride the bike.

## Correlation Matrix 
![image](https://github.com/nshah-11/divvy-bikesharing/assets/97864887/80f825de-a23b-4b73-983a-84a0dee978eb)

Little to no correlation between variables so all variables were used to train model. 

*The code for this can be found under model_training folder in RF_SVM_ARIMA_NS.R file.  
