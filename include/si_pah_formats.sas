/*********************************************************************************************************
DESCRIPTION: List of potentially avoidable hospitalisations

INPUT:
NA


OUTPUT:
$pah = format that contains readcodes relating to pah

AUTHOR: W Lee

DEPENDENCIES: 

NOTES: 


HISTORY: 
14 Jul 2017 EW v1
*********************************************************************************************************/

proc format;
value $pah
'A150'-'A1999','B900'-'B9099','M011'-'M0119','P370'-'P3709'='01 Tuberculosis'
'B20'-'B2499'='02 HIV AIDS'
'C00'-'C0099','C43'-'C4399','C44'-'C4499'='03 Skin cancers'
'C01'-'C0699','C09'-'C0999','C10'-'C1099'='04 Oral cancers'
'C18'-'C2199'='05 Colo-rectal cancer'
'C33'-'C3499'='06 Lung cancer'
'C50'-'C5099'='07 Breast cancer'
'D50'-'D5399','E40'-'E4699','E50'-'E6499','M833'-'M8339','R64'-'R6499'='08 Nutrition'
'F10'-'F1099','I426'-'I4269','K290'-'K2909','K70'-'K7099'='09 Alcohol related conditions'
'I21'-'I2399','I241'-'I24199'='10 a Myocardial infarction'
'I240'-'I2409','I248'-'I2489','I249'-'I2499','I25'-'I2599'='10 b Other ischaemic heart disease'
'A02'-'A0999','K529'-'K5299'='11 Gastroenteritis'
'A23'-'A2399','A26'-'A2699','A28'-'A2899','A32'-'A3299','A38'-'A3899','A46'-'A4699','B50'-'B5499','P23'-'P2399','P351'-'P35199','P352'-'P35299','P358'-'P35899','P359'-'P35999','P36'-'P3699','P371'-'P37999'='12 Other infections'
'A413'-'A4139','A492'-'A4929','B9631','B9639','G000'-'G0009'='13 a Immunisation preventable - Hib'
'B05'-'B0599','B06'-'B0699','B26'-'B2699','M014'-'M0149','P350'-'P3509'='13 b Immunisation preventable - MMR'
'A37'-'A3799'='13 c Immunisation preventable - Whooping cough'
'A33'-'A3699','A80'-'A8099'='13 d Immunisation preventable - Other'
'B15'-'B1999','C220'-'C2209','C221'-'C2219','C229'-'C2299','P353'-'P3539'='14 Hepatitis and liver cancer'
'A50'-'A5999','A60'-'A6099','A63'-'A6399','A64'-'A6499','I980'-'I9809','M023'-'M0239','M031'-'M0319','M730'-'M7309','M731'-'M7319','N290'-'N2909','N341'-'N3419','N70'-'N7799','O00'-'O0099'='15 Sexually transmitted diseases'
'C53'-'C5399'='16 Cervical cancer'
'E00'-'E0599','E890'-'E8909'='17 Thyroid disease'
'E10'-'E1499','E162'-'E1629'='18 Diabetes'
'E86'-'E8699','E870'-'E87099'='19 Dehydration'
'G40'-'G4199','O15'-'O1599','R560'-'R5609','R568'-'R5689'='20 Epilepsy'
'H65'-'H6799','H70'-'H7099','J01'-'J0399'='21 ENT infections'
'I00'-'I0999'='22 Rheumatic fever/heart disease'
'I10'-'I1599','I674'-'I6749'='23 Hypertensive disease'
'I20'-'I2099','R072'-'R0749'='24 Angina and chest pain'
'I50'-'I5099','J81'-'J8199'='25 Congestive heart failure'
'I61'-'I6199','I63'-'I6699'='26 Stroke'
'J21'-'J2199'='27 a Respiratory infections - Acute bronchiolitis'
'J13'-'J1699','J18'-'J1899'='27 b Respiratory infections - Pneumonia'
'J00'-'J0099','J06'-'J0699','J10'-'J1199','J20'-'J2099'='27 c Respiratory infections - Other'
'J40'-'J4499','J47'-'J4799'='28 CORD'
'J45'-'J4699'='29 Asthma'
'K00'-'K0699','K08'-'K0899'='30 Dental conditions'
'K25'-'K2899'='31 Peptic ulcer'
'K350'-'K3509','K351'-'K3519'='32 Ruptured appendix'
'K400'-'K4019','K403'-'K4049','K410'-'K4119','K413'-'K4149','K420'-'K4219','K430'-'K4319','K440'-'K4419','K450'-'K4519','K460'-'K4619'='33 Obstructed hernia'
'N10'-'N1099','N12'-'N1299','N136'-'N1369','N390'-'N3909'='34 Kidney/urinary infection'
'H000'-'H0009','H010'-'H0109','H050'-'H0509','J340'-'J3409','K122'-'K1229','L01'-'L0499','L08'-'L0899','L980'-'L9809'='35 Cellulitis'
'R62'-'R6299','R633'-'R6339','P923'-'P9239'='36 Failure to thrive'
'R02'-'R0299'='37 Gangrene'
'A39'-'A3999','M010'-'M0109','M030'-'M0309'='38 Meningococcal infection'
'A481'-'A4819','A482'-'A4829'='39 Legionnaires disease'
other='Other'
;
run;