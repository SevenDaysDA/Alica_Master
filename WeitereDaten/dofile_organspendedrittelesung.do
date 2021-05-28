

set more off

global path "C:\Users\Cyprien\Desktop\Datenanalyse"

cd "$path\Rohdaten"
import excel "organspende_drittelesung_final.xlsx", first case(lower) clear





*******************************************************************************

* 1. Anpassen des Datensatzes
* a. Entfernen nicht relevanter Dinge

* Keine Abstimmung
drop if enthaltung == 2 | nichtabgegeben == 4 

* Variablen
drop a1n710 ungültig enthaltung nichtabgegeben nein


replace bildung = "" if bildung == "?"
destring bildung, replace

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

lab var ja "Abstimmung"

********************************

gr bar (mean) ja, over(fraktion)

* 3. Logistische Regression
encode fraktiongruppe, gen(fraktion)

logit ja ib2.fraktion i.alter i.geschlecht, or

logit ja ib2.fraktion i.alter i.geschlecht i.bildung, or

logit ja ib2.fraktion i.alter i.geschlecht studium, or

