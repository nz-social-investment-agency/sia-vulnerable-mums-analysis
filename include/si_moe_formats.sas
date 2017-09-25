/*	 ncea qualifcations ;*/
	proc format;
		value nceaqual 
			42='national diploma at level 4 or above'
			41='national certificate at level 4 or above'
			40='new zealand scholarship award'
			39='ncea level 3 (with excellence)'
			38='ncea level 3 (with merit)'
			37='ncea level 3 (with achieve)'
			36='ncea level 3 (no endorsement)'
			35='other nqf qualification at level 3'
			29='ncea level 2 (with excellence)'
			28='ncea level 2 (with merit)'
			27='ncea level 2 (with achieve)'
			26='ncea level 2 (no endorsement)'
			25='other nqf qualification at level 2'
			19='ncea level 1 (with excellence)'
			18='ncea level 1 (with merit)'
			17='ncea level 1 (with achievement)'
			16='ncea level 1 (no endorsement)'
			15='other nqf qualification at level 1';

/*** tertairy code to nqf level **/
		value lv8id
			40,41,46, 60, 96, 98 =1
			36-37,43             =2
			30-35                =3
			20,21,25             =4
			12-14                =6
			11                   =7
			01,10                =8
			90, 97, 99           =9
			other                =.;


/*** tertiary level qualifciation ***/
	value qacccode
			01  = "higher doctorate"
			10  = "phd"
			11  = "masters"
			12  = "bachelors with honours"
			13  = "post-graduate diplomas"
			14  = "post-graduate certificates"
			20  = "bachelors"
			21  = "graduate diploma/ certificate"
			25  = "certificate of proficiency (credit to a degree)"
			30  = "professional association diploma"
			31  = "national diploma/ national certificate levels 5-7"
			32  = "new zealand diploma"
			33  = "diploma/ certificate issued by teo"
			34  = "advanced trade certificate"
			35  = "new zealand certificate/ technicians certificate"
			36 = "national certificate level 4 and other level 4 certificates"
			37 = "certificate of proficiency (credit to a diploma)"
			40 = "professional association certificate"
			41 = "national certificate levels 1-3"
			43 = "trade certificate level 4"
			46 = "certificate issued by teo"
			60 = "licence"
			90 = "certificate of personal interest"
			96 = "star"
			97 = "programmes of study taught under contract"
			98 = "programmes of study made up of selected unit standards"
			99 = "community education programmes"
			other = "!format error qacccode!";
			
/***qualification from census***/
		/*formats*/
		value $sec_qual 00='no qualification'
			01='level 1 certificate'
			02='level 2 certificate'
			03='level 3 or 4 certificate'
			23='overseas secondary school qualification'
			other='missing';
		value $postsec_qual 00= 'no post-school qualification' 
			01= 'level 1 certificate' 
			02= 'level 2 certificate' 
			03= 'level 3 certificate' 
			04= 'level 4 certificate' 
			05= 'level 5 diploma' 
			06= 'level 6 diploma' 
			07= 'bachelor degree and level 7 qualification' 
			08= 'post-graduate and honours degrees' 
			09= 'masters degree' 
			10= 'doctorate degree'
			other= 'missing';
		value $highest_qual 00= 'no qualification' 
			01= 'level 1 certificate' 
			02= 'level 2 certificate' 
			03= 'level 3 certificate' 
			04= 'level 4 certificate' 
			05= 'level 5 diploma' 
			06= 'level 6 diploma' 
			07= 'bachelor degree and level 7 qualification' 
			08= 'post-graduate and honours degrees' 
			09= 'masters degrees'
			10= 'doctorate degree' 
			11= 'overseas secondary school qualification' 
			other='missing';
		value $highest_qual_lev 'no qualification' , 'missing' = 0
			'level 1 certificate' = 1
			'level 2 certificate' = 2
			'level 3 certificate', 'overseas secondary school qualification' = 3
			'level 4 certificate' = 4
			'level 5 diploma' = 5
			'level 6 diploma' = 6
			'bachelor degree and level 7 qualification' = 7
			'post-graduate and honours degrees' = 8
			'masters degrees' = 9
			'doctorate degree' = 10;
	run;