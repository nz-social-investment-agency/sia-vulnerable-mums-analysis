# sia-vulnerable-mums-analysis

## Overview
This repository contains code to perform exploratory analysis and identify natural clusters among mothers and their children along with key characteristics that describe each of these clusters. The objective of this analysis is to check whether there are distinctive patterns in the data that describe groups with risk of bad outcomes. Instead of relying purely on the presence or absence of a risk factor for a particular individual, we attempt to create fuzzy groupings of individuals that look quite similar to each other in terms of their characteristics, and then identify groups that register highly on risk factor variables. This work is part of exploratory analysis for identification of priority populations.

## Dependencies
* It is necessary to have an IDI project if you wish to run the code. Visit the Stats NZ website for more information about this.
* Code dependencies are captured via submodules in this repository. You will find the submodules in the `lib` folder of this repository. To ensure you clone the submodules as well, use `git clone --recursive https://github.com/nz-social-investment-agency/vulnerable_mothers.git`. Regular cloning or downloading of the zip file will result in all the `lib` subfolders being empty. Currently the code dependencies for the vulnerable mothers repository are -
	* `social_investment_analytical_layer (SIAL)` 
	* `social_investment_data_foundation (SIDF)` 
	* `SIAtoolbox`
	* `mha_data_definition`

* Once the repository is downloaded and put into your IDI project folder, run the `social_investment_analytical_layer` scripts so that the all the SIAL tables are available for use in your database schema. We strongly recommended using the version in the submodule. Note when you create the SIAL tables the scripts will attempt to access to the following schemas in IDI_Clean (or the archives if you wish to use an older IDI refresh). 
	* acc_clean
	* cor_clean
	* cyf_clean
	* data
	* dia_clean
	* hnz_clean
	* moe_clean
	* moh_clean
	* moj_clean
	* msd_clean
    * pol_clean
	* security
* If there are specific schemas listed above that you don't have access to, the **SIAL** main script (after it finishes running) will give you a detailed report on which SIAL tables were not created and why.
* Ensure that you have installed the `SIAtoolbox` library in R. Note that `SIAtoolbox` is not on the CRAN repository, and can be retrieved only from Github. Place this code in a folder in your IDI project, make sure you have the `devtools` package installed and loaded in R and then run `devtools::install("/path/to/file/SIAtoolbox")` in R.
* You can use the `social_investment_data_foundation (SIDF)` to roll up only those SIAL tables that were created. All these macros are made available via a `sasautos` call to the relevant `lib` folder. If you attempt to run the data foundation to create a variable from SIAL table that does not exist in your schema, the variables won't be created. You won't get an error, the variable just won't exist.

## Folder descriptions
This folder contains all the code necessary to build characteristics and service metrics. Code is also given to create an outcome variable (highest qualification) for use and as an example of how the more complex variables are created and added to the main dataset.

**include:** This folder contains generic formatting scripts.
**lib:** This folder is used to refer to reusable code that belongs to other repositories
**sasautos:** This folder contains SAS macros. All scripts in here will be loaded into the SAS environment during the running of setup in the main script.
**sasprogs:** This folder contains SAS programs. The main script that builds the dataset is located in here as well as the control file that needs to be populated with parameters for your analysis. 
**sql:** This folder contains sql scripts to query the database.

## Instructions to run the vulnerable mothers project
### Step A: Create population
1. Start a new SAS session
2. Open `sasprogs/si_control_general.sas`. Go to the yellow datalines and update any of the parameters that need changing. The one that is most likely to change if you are outside the SIA is the `si_proj_schema`. If you have made changes save and close the file
3. Open `sasprogs/si_control_mother.sas`. Go to the yellow datalines and update any of the parameters that need changing. These parameters are likely to change if you wish to extend the vulnerable mothers analysis to include additional variables. If you have made changes save and close the file.
4. Repeat step 3 for the `sasprogs/si_control_child.sas` control file. 
5. Open `sasprogs/si_main.sas` and change the ``si_source_path` variable to your project folder directory. Once this is done, run the `si_main.sas` script, which will build the datasets that are needed to do the analysis.

### Step B: Data Preparation & Analysis
1. Open up `rprogs/main.R` This script controls all pieces of work done in R. The first part of the script sets the directories and loads the libraries. If you are doing work outside the SIA change the working directory to your project folder. 
2. Confirm that you have all the packages installed in the load library section. Run the `main.R` script to create the analysis outputs. Note that the scripts perform 

### Step C: Identifying vulnerable groups and their characteristics
1. Check the `output` folder for outputs from the cluster analysis. A lasso regression is performed to identify a set of variables that strongly characterise each cluster. Clusters that exhibit high coefficients for risk factors can be thought of as at-risk groups. 


## Getting Help
If you have any questions email info@sia.govt.nz Tracking number: SIA-2017-0261
