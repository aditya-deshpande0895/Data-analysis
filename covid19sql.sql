create database if not exists COVID;
use covid;
-- drop table covid_19;
select * from covid_19;

create table if not exists regdates as
select t.sno,concat(t.year,'-',t.month,'-',t.day) as Regdate from
(select sno,substr(date,1,2) as day,substr(date,4,2) month,substr(date,7) year ,date from covid_19) as t;
-- drop table regdates;
select * from regdates;
describe regdates;

-- Convert datatype of Regdate column to Date 
ALTER TABLE `covid`.`regdates` 
CHANGE COLUMN `Regdate` `Regdate` DATE NULL DEFAULT NULL ;

describe regdates;
select * from regdates;

ALTER TABLE `covid`.`covid_19` 
DROP COLUMN `Date`;
select * from covid_19;

create table if not exists newcovid_19 as
(select c.sno,r.regdate,c.time,c.stateunionterritory,c.confirmedIndianNational,c.confirmedForeignNational,
 c.cured,c.deaths,c.confirmed from covid_19 c inner join regdates r
 on r.sno=c.sno);
 
 select * from newcovid_19;
 describe newcovid_19;
 drop table if exists covid_19;
 
 select regdate,stateunionterritory from newcovid_19
  order by stateunionterritory,regdate;
  
  create or replace view confirm as
  select t.regdate,t.stateunionterritory,t.confirmed-t.prevdayconfirm as Dailyconfirm,t.confirmed,t.prevdayconfirm from
 (select regdate,stateunionterritory,confirmed,
  lag(confirmed,1,0) over(partition by stateunionterritory order by regdate) prevdayconfirm
  from newcovid_19) t;
 
 create or replace view cured as
 select t.regdate,t.stateunionterritory,t.cured-t.nextdaycured as dailycured,t.cured,t.nextdaycured from
 (select regdate,stateunionterritory,cured,
  lag(cured,1,0) over(partition by stateunionterritory order by regdate) nextdaycured
  from newcovid_19) t;
  
  create or replace view death as
  select t.regdate,t.stateunionterritory,t.deaths-t.prevdaydeath as dailydeath,deaths,t.prevdaydeath from
 (select regdate,stateunionterritory,deaths,
  lag(deaths,1,0) over(partition by stateunionterritory order by regdate) prevdaydeath
  from newcovid_19) t;
  
select * from newcovid_19;
select * from confirm;
select * from cured;
select * from death;
select m.sno,m.regdate,m.time,m.confirmedIndianNational,m.confirmedForeignNational,
       t1.Dailyconfirm,t1.confirmed,t2.dailycured,t2.cured,t3.dailydeath,t3.deaths
from newcovid_19 as m,confirm as t1,cured as t2,death as t3
where m.regdate=t1.regdate=t2.regdate=t3.regdate;

select t1.dailyconfirm,t2.dailycured,t3.dailydeath,
m.sno,m.regdate,m.time,m.confirmedIndianNational,m.confirmedForeignNational,m.stateunionterritory,
m.cured as cured_cum,m.deaths as deaths_cum,m.confirmed as confirm_cum
from confirm as t1 inner join newcovid_19 as m 
on t1.regdate=m.regdate and t1.stateunionterritory=m.stateunionterritory 
inner join cured as t2 on t2.regdate=t1.regdate and t2.stateunionterritory=m.stateunionterritory
inner join death as t3 on t3.regdate=t2.regdate and t3.stateunionterritory=m.stateunionterritory; 
