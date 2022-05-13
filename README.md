# wave-r-data-table - R data.table tutorial in [wave](https://github.com/h2oai/wave)
This wave application is a R data.table tutorial and interactive learning environment developed using the wave library for R.


## App Description: 
The R data.table tutorial in h2owave teaches R and data science enthusiasts an interactive way to R data.table, one of the most powerful, and popular data handling library in R.  

**Audience:** Enthusiast, Newcomer, Advanced User

## Pre-requirements

1. Open an `R` environment
2. Run `pre.req.install.R` by running the script in the R IDE using `source("pre.req.install.R")` command. 
3. Follow prompts from the previous command and install the required libraries. 
4. Download [wave](https://github.com/h2oai/wave)
5. Change your current directory to `r/`
6. Run `make package` (The command will generate an R package `h2owave.[version].tar.gz`)
7. Install the R package using the command `R CMD INSTALL h2owave.[version].tar.gz`

## Run wave app

1. Now run the wave app using `Rscript datatable.R`
2. Use a browser and access `http://localhost:10101/`
3. Using should be able to use the wave app now. 

