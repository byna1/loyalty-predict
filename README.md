![alt text](image. png)

## DESCRIPTION OF DATA

### USER FEATURES

**ActFrequency**: Quantity of times the person came to the live 
**QtdTransactions:** Quantity of times theW person interacted in the live chat 
**REVENUE_POINTS: **Points of the person at the fidelity program at this moment.
**SUM_OF_POINTS:** Sum of points in a specific window of time 


**transactions_day:** is the reason between the transactions made from an user and the amount of days they were online on the live.
**PCT_ATIVATION_MAU:** is the reason between the transactions made from an user and the amount of days they were online on the live in total, since the day they joined the channel.

**Total_minutes_per_day**: Total of hours that the user remained active on the live per day 


**dif_day**: it's the day an user spent on average for being online in the live. (life, 7, 28, ...)



**qtTransactionperperiodofday**: This is the metric that measures the quantity of interactions of the user on each time of the day. Since the time is in UTC and the lives are happening in UTC + 4, the tourn hours are thinking taking this into consideration. so, morning is 10 to 14, afternoon is 14 to 21, and night is 21 to 7. 

**pctTransaction**: Normalizes the numbers of each person in comparisson with herself.  counts the engagement of this person on each time of the day. That way, if that person is more active during the morning, day of afternoon without considering the absolute number of interactions but the existance of interactions themselves. 