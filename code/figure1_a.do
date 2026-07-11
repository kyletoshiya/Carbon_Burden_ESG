

***************************
******Figure 1-Panel A*****
***************************


use "${data}/EPA_SCC.dta", replace
replace discount15=discount15/1000
replace discount20=discount20/1000
replace discount25=discount25/1000
twoway ///
    (line discount15 year, lcolor("213 94 0")   lwidth(medthick) lpattern(dash)) ///
    (line discount20 year, lcolor("0 114 178")   lwidth(medthick) lpattern(solid)) ///
    (line discount25 year, lcolor("0 158 115")   lwidth(medthick) lpattern(longdash)) ///
    , ///
    xlabel(2020(20)2105) ///
    ylabel(0(200)1000) ///
    xtitle("Year") ///
    ytitle("Thousands of KRW per tCO2-eq") ///
    legend(order(1 "Discount rate = 1.5%" 2 "Discount rate = 2.0%" 3 "Discount rate = 2.5%") ///
           position(6) row(1) ///
           region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white)
