select w.id_vogel, date_part('year',w.datum) jaar, date_part('month',w.datum) maand, date_part('day',w.datum) dag, eea_1km gridcel, w.aantal    --select species, year, month, day, gridcell and number of individuals
from waarneming w
	inner join wnmn_gis as gis on (w.id = gis.w_id) --link to geographical layer

where 	w.id_vogel in (409,401,418,389) --4 day active mammal species
and	date_part('year',w.datum) > 1999 --time period 2000-2018
and	date_part('year',w.datum) < 2019
and	w.aantal <> 0			-- number of individuals needs to be different from zero 
and 	w.zeker = 'J' 			-- only observervations of which the observer is sure are included
and 	w.ind_moderated not in ('N')	-- no observations which are considered to be incorrect by validators 
and	w.id_activiteit not in (18,27,57,66,67,68,2016,2024,2026,3056,3057,3064,3100,3150,3175,3179) -- we aim at the visual observations. No traffic victims, excrements, footprints,... 
and	id_activiteit not in (3177,3064)-- No camera trap observations 
and exact_meters <999 			-- geographical precision is higher than 999m  
