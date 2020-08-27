-- select all dragonflies with more than 30 recordings, create a temp table a 
drop table if exists a;
create temp table a
as
(select v.id, naam_nl, naam_lat, count(distinct(w.id)) aantal
from vogel v
inner join waarneming w on (w.id_vogel=v.id)
where v.ind_diergroep in (5)			--dragonflies
and id_species_type not in ('H','M')		--no multispecies
and date_part('year',w.datum) > 1999		--2000-2018
and date_part('year',w.datum) <2019
and w.id_activiteit not in (3103,3113) 		--no catch by cat or tracks 
and w.id_kleed not in (41,131,1104,1116) 	--No larvae, exuvia, egg or pro-larvae
and 	w.ind_moderated not in ('N')		--no observations which are considered to be incorrect by validators 
and	w.aantal <> 0 				--number of individuals needs to be different from zero 
and 	w.zeker = 'J'				--only observervations of which the observer is sure are included
and exact_meters <999 				--geographical precision is higher than 999m 
group by v.id, naam_nl, naam_lat
order by count(distinct(w.id)) desc
limit 67);


select distinct(a.id), naam_nl, naam_lat
from a
order by id asc

-- calculate the percentage of observations to determine the flight period
drop table if exists b;
create temp table b
as
(
select a.id, date_part('month',w.datum) maand, date_part('day',w.datum) dag,a.aantal aantal_totaal, count(distinct(w.id)) aantal_vandaag, count(distinct(w.id))::decimal / a.aantal percentage, row_number() OVER (PARTITION BY a.id ORDER BY a.id) AS rnum  
from a
inner join waarneming w on (w.id_vogel=a.id)
where date_part('year',w.datum) > 1999		-- for parameter explanation, see above
and date_part('year',w.datum) <2019
and w.id_activiteit not in (3103,3113) 
and w.id_kleed not in (41,131,1104,1116) 
and 	w.ind_moderated not in ('N')
and	w.aantal <> 0 
and 	w.zeker = 'J'
and exact_meters <999  
group by a.id,date_part('month',w.datum), date_part('day',w.datum), a.aantal);



drop table if exists c;
create temp table c
as
(
select *, SUM(percentage) OVER (ORDER BY id, maand, dag) AS balance
from b);

drop table if exists d;
create temp table d
as
(
select id,maand, dag,aantal_totaal,aantal_vandaag, balance , floor(balance), balance-floor(balance) percentage_van_de_vliegperiode  
from c);

-- select only the 90% flightperiod 
select * from d
where percentage_van_de_vliegperiode >= 0.05
and percentage_van_de_vliegperiode <= 0.95
-- Er is een tabel met de vliegperiode van de libellen gemaakt


-- select data
drop table if exists excl_vliegp;
create temp table excl_vliegp
as
(
select w.id_vogel, date_part('year',w.datum) jaar, date_part('month',w.datum) maand, date_part('day',w.datum) dag, eea_1km gridcel, w.aantal    
from waarneming w
	inner join wnmn_gis as gis on (w.id = gis.w_id)

where 	w.id_vogel in (587,594,631,616,640,641,613,589,578,590,629,627,585,610,1524,579,621,598,633,583,580,599,634,632,611,600,628,584,615,588,596,595,642,608,604,637,644,581,582,617,597,619,639,646,624,645,612,635,630,606,623,592,603,638,591,609,593,620,618,643,602,625,622,626,614,636,79647) --alle libellen met meer dan 30 wnmn
and	date_part('year',w.datum) > 1999
and	date_part('year',w.datum) < 2019
and w.id_activiteit not in (3103,3113) --geen vangst door kat, sporen, 
and w.id_kleed not in (41,131,1104,1116) --larve/nimf, larvenhuidje, ei, prolarve
and 	w.ind_moderated not in ('N')
and	w.aantal <> 0 
and 	w.zeker = 'J'
and exact_meters <999
order by w.id_vogel asc,date_part('month',w.datum) asc,date_part('day',w.datum) asc) -- nauwkeurigheid moet kleiner zijn dan een km. En staat als 999 gedefinieerd in de website.  


-- starting from these excl_vliegp the observations within the flightperiod were selected for analysis