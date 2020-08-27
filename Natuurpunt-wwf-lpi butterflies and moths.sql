select v.naam_lat, rights authority, v.id soortid_waarnemingen, w.datum, 
replace(cast(st_y(w.geo_point) as character varying),'.',',') AS y_coordinate,				-- WGS84-coord.
	replace(cast(st_x(w.geo_point) as character varying),'.',',') AS x_coordinate,				-- WGS84-coord.
	tk.oms levensstadium, tk.oms_en lifestage, ta.oms gedrag_methode, ta.oms_en behaviour_method, w.aantal, w.exact_meters geographic_uncertainty
from waarneming w
inner join type_kleed tk on (tk.id=w.id_kleed)			--lifestage
inner join type_activiteit ta on (ta.id=w.id_activiteit)	--activity
inner join vogel v on (w.id_vogel=v.id)

where w.ind_diergroep in (4,8)					--butterflies and moths
and date_part('year',w.datum) > 1999				--2000-2018
and date_part('year',w.datum) <2019
and id_species_type not in ('H','M')				--multispecies excluded
and 	w.ind_moderated not in ('N')				-- no observations which are considered to be incorrect by validators 
and	w.aantal <> 0 						-- number of individuals needs to be different from zero 
and 	w.zeker = 'J'						-- only observervations of which the observer is sure are included
and exact_meters <999						-- geographical precision is higher than 999m 