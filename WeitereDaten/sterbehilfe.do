

set more off

global path "C:\Users\Cyprien\Desktop\Datenanalyse"

cd "$path\Rohdaten"
import excel "organspende_drittelesung_final.xlsx", first case(lower) clear

keep name vorname altersgruppe geschlecht bildungsgrad

ren altersgruppe alter
ren geschlecht sex
ren bildungsgrad bildung

replace bildung = "" if bildung == "?"
destring bildung, replace

cd "$path\Daten"
save organspende_demo, replace


cd "$path\Rohdaten"
import excel "Sterbehilfe.xlsx", first case(lower) clear

replace bildungsgrad = "" if bildungsgrad == "?"
destring bildungsgrad, replace

egen nmiss = rowmiss(altersgruppe geschlecht bildungsgrad)

drop if nmiss == 3
drop nmiss

cd "$path/Daten"
save sterbehilfe1, replace

cd "$path\Rohdaten"
import excel "Sterbehilfe.xlsx", first case(lower) clear

replace bildungsgrad = "" if bildungsgrad == "?"
destring bildungsgrad, replace

egen nmiss = rowmiss(altersgruppe geschlecht bildungsgrad)

keep if nmiss == 3

merge 1:1 name vorname using organspende_demo

replace altersgruppe = alter if nmiss == 3
replace bildungsgrad = bildung if nmiss == 3
replace geschlecht = sex if nmiss == 3

drop if _merge == 2
drop alter bildung sex nmiss _merge

cd "$path/Daten"
save sterbehilfe2, replace

cd "$path/Daten"
use sterbehilfe1, clear

app using sterbehilfe2

sort fraktiongruppe name

cd "$path/Daten"
save sterbehilfe, replace

cd "$path/Rohdaten"
export excel using sterbehilfe_komplett.xlsx, first(var) replace


cd "$path/Daten"
use sterbehilfe, clear

ren altersgruppe alter
ren bildungsgrad bildung


* 1. Anpassen des Datensatzes
* a. Entfernen nicht relevanter Dinge

* Keine Abstimmung
drop if enthaltung == 1 | nichtabgegeben == 1

* Variablen
drop ungültig enthaltung nichtabgegeben nein n


cap drop studium
gen studium = .
replace studium = 1 if bildung == 1
replace studium = 0 if inrange(bildung,2,3)


* Label setzen
label define age_group 1 "< 40 Jahre" 2 "40 bis < 60 Jahre" 3 "Ueber 60 Jahre"
label values alter age_group

label define bild 1 "Studienabschluss" 2 "Abitur" 3 "kein Abitur"
label values bildung bild

label define janein 1 "ja" 0 "nein"
label values ja janein

label values studium janein
label variable studium "Studienabschluss"

**************************

* 2. Deskriptive Darstellung
* Abstimmung
tab ja

* Fraktionszugehoerigkeit
tab fraktiongruppe
tab fraktiongruppe ja, row

* Altersgruppe
tab alter
tab alter ja, row

* Bildungsstatus

* Geschlechter 
tab geschlecht
label define frau 1 "weiblich" 0 "maennlich"
label values geschlecht frau

encode fraktiongruppe, gen(fraktion)

mvdecode geschlecht, mv(2)

lab var ja "Abstimmung"

********************************

gr bar (mean) ja, over(fraktion)

* 3. Logistische Regression


logit ja i.fraktion i.alter i.geschlecht, or
eststo log1

logit ja i.fraktion i.alter i.geschlecht i.bildung, or
eststo log2

logit ja i.fraktion i.alter i.geschlecht studium, or
eststo log3

cd "$path/Tables"
esttab log1 log2 log3 using regtab1, rtf replace ///
	se(3) b(3) nonumbers nobase noomit label ///
	drop(_cons) stats(r2_p, label("Pseudo R^2") fmt(2))





