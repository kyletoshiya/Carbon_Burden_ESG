
global directory = "/Users/kyle/Library/CloudStorage/Dropbox/Carbon Burden/Replication Package"



*************************************

global data = "${directory}/data"
global graph = "${directory}/graph"

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
graph export "${graph}/scc.png", replace


***************************
******Figure 1-Panel B*****
***************************

use "${data}/carbon_burden.dta", clear
collapse (sum) cb15_2050 cb15_2080 cb15_2100 cb20_2050 cb20_2080 cb20_2100 cb25_2050 cb25_2080 cb25_2100 marketvalue_end
global variable cb15_2050 cb15_2080 cb15_2100 cb20_2050 cb20_2080 cb20_2100 cb25_2050 cb25_2080 cb25_2100
foreach f of global variable {
gen `f'_v = `f'/marketvalue_end
}
* 1. long 변환을 위한 준비
rename cb15_2050 v_15_2050
rename cb15_2080 v_15_2080
rename cb15_2100 v_15_2100
rename cb20_2050 v_20_2050
rename cb20_2080 v_20_2080
rename cb20_2100 v_20_2100
rename cb25_2050 v_25_2050
rename cb25_2080 v_25_2080
rename cb25_2100 v_25_2100
gen id=1
* 2. reshape long
reshape long v_15_ v_20_ v_25_, i(id) j(year) string
* year 변수 숫자로 변환
destring year, replace
* 3. 각 연도별 평균 계산
collapse (mean) v_15_ v_20_ v_25_, by(year)
label define yearlab 2050 "Through 2050" 2080 "Through 2080" 2100 "Through 2100"
label values year yearlab
replace v_15_ =  v_15_/1000000000000
replace v_20_ = v_20_/1000000000000
replace v_25_ = v_25_/1000000000000
* 4. 바 그래프
graph bar v_15_ v_20_ v_25_, ///
    over(year) ///
    bar(1, color("213 94 0%80"))   ///
    bar(2, color("0 114 178%80"))  ///
    bar(3, color("0 158 115%80")) ///
    legend(order(1 "Discount rate = 1.5%" 2 "Discount rate = 2.0%" 3 "Discount rate = 2.5%") pos(6) row(1)) ///
    ytitle("Carbon burden (Trillions of KRW)") ///
    graphregion(color(white)) bgcolor(white)
graph export "${graph}/cb.png", replace



***************************
******Figure 1-Panel C*****
***************************


use "${data}/carbon_burden.dta", clear
collapse (sum) cb15_2050 cb15_2080 cb15_2100 cb20_2050 cb20_2080 cb20_2100 cb25_2050 cb25_2080 cb25_2100 marketvalue_end

global variable cb15_2050 cb15_2080 cb15_2100 cb20_2050 cb20_2080 cb20_2100 cb25_2050 cb25_2080 cb25_2100
foreach f of global variable {
gen `f'_v = `f'/marketvalue_end
}

* 1. long 변환을 위한 준비
rename cb15_2050_v v_15_2050
rename cb15_2080_v v_15_2080
rename cb15_2100_v v_15_2100
rename cb20_2050_v v_20_2050
rename cb20_2080_v v_20_2080
rename cb20_2100_v v_20_2100
rename cb25_2050_v v_25_2050
rename cb25_2080_v v_25_2080
rename cb25_2100_v v_25_2100
gen id=1

* 2. reshape long
reshape long v_15_ v_20_ v_25_, i(id) j(year) string

* year 변수 숫자로 변환
destring year, replace

* 3. 각 연도별 평균 계산
collapse (mean) v_15_ v_20_ v_25_, by(year)


label define yearlab 2050 "Through 2050" 2080 "Through 2080" 2100 "Through 2100"
label values year yearlab


* 4. 바 그래프
graph bar v_15_ v_20_ v_25_, ///
    over(year) ///
    bar(1, color("213 94 0%80"))   ///
    bar(2, color("0 114 178%80"))  ///
    bar(3, color("0 158 115%80")) ///
    legend(order(1 "Discount rate = 1.5%" 2 "Discount rate = 2.0%" 3 "Discount rate = 2.5%") pos(6) row(1)) ///
    ytitle("Carbon burden to equity value ratio") ///
    graphregion(color(white)) bgcolor(white)

graph export "${graph}/cb_equity.png", replace	 



**********************************
******Figure 2-Panel A,C,E,G******
**********************************
global dataset sus kcgs msci ref
foreach j of global dataset {
use "${data}/cb_`j'_cleaned.dta", replace

    if "`j'" == "sus"  local color "41 101 235"
    if "`j'" == "kcgs" local color orange
    if "`j'" == "msci" local color "21 164 74"
    if "`j'" == "ref"  local color "124 58 237"

    correlate z_esg lncb20
    local r = r(rho)
    local r_fmt: display %4.2f `r'
    local n = r(N)
    local t = `r' * sqrt(`n' - 2) / sqrt(1 - `r'^2)
    local p = 2 * ttail(`n' - 2, abs(`t'))
    local star = cond(`p'<0.01, "***", cond(`p'<0.05, "**", cond(`p'<0.1, "*", "")))
    twoway (scatter z_esg lncb20, mcolor("`color'%60") msize(medium)) ///
           (lfit z_esg lncb20, lcolor("`color'") lpattern(line) lw(medthick)), ///
           yscale(range(-4 4)) ylabel(-4 -2 0 2 4) ///
           xlabel(25(2.5)35) xtitle("") ///
           text(4 35 "Correlation coefficient = `r_fmt'`star'", color("`color'") size(medium) place(w)) ///
           legend(off) ///
           name(esg_`j', replace) ///
		   xtitle("Carbon burden (log)") ///
		   ytitle("Standardized ESG score")
    graph export "${graph}/esg_`j'.png", replace	    
}






**********************************
******Figure 2-Panel B,D,F,H******
**********************************


global dataset sus kcgs msci ref
foreach j of global dataset {
use "${data}/cb_`j'_cleaned.dta", replace

    if "`j'" == "sus"  local color "41 101 235"
    if "`j'" == "kcgs" local color orange
    if "`j'" == "msci" local color "21 164 74"
    if "`j'" == "ref"  local color "124 58 237"

    correlate z_e lncb20
    local r = r(rho)
    local r_fmt: display %4.2f `r'
    local n = r(N)
    local t = `r' * sqrt(`n' - 2) / sqrt(1 - `r'^2)
    local p = 2 * ttail(`n' - 2, abs(`t'))
    local star = cond(`p'<0.01, "***", cond(`p'<0.05, "**", cond(`p'<0.1, "*", "")))
    twoway (scatter z_e lncb20, mcolor("`color'%60") msize(medium)) ///
           (lfit z_e lncb20, lcolor("`color'") lpattern(line) lw(medthick)), ///
           yscale(range(-4 4)) ylabel(-4 -2 0 2 4) ///
           xlabel(25(2.5)35) xtitle("") ///
           text(4 35 "Correlation coefficient = `r_fmt'`star'", color("`color'") size(medium) place(w)) ///
           legend(off) ///
           name(e_`j', replace) ///
		   xtitle("Carbon burden (log)") ///
		   ytitle("Standardized environmental score")
    graph export "${graph}/e_`j'.png", replace	    
}



****************************
******Figure 3-Panel A******
****************************

global dataset sus kcgs msci ref
foreach j of global dataset {

use "${data}/cb_`j'_cleaned.dta", clear
egen ind_2digits=group(industry_group)
gen large=0
replace large=1 if firmsize=="대기업"
gen age2=age^2
gen age3=age^3
eststo `j': reg z_esg lncb20 age age2 age3 i.ind_2digits i.large

}

coefplot ///
    (sus, label("Sustinvest")  msymbol(circle) mcolor("41 101 235") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("41 101 235") lwidth(medthick))) ///
    (msci, label("MSCI")  msymbol(circle) mcolor("21 164 74") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("21 164 74") lwidth(medthick))) ///
    (kcgs, label("KCGS") msymbol(circle) mcolor(orange) msize(medlarge) ///
    ciopts(recast(rcap) lcolor(orange) lwidth(medthick))) ///
    (ref, label("Refinitiv")     msymbol(circle) mcolor("124 58 237") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("124 58 237") lwidth(medthick))) ///
	, keep(lncb20) ylabel(, angle(vertical)) ///
	legend(pos(6) row(1)) ///
	xline(0) ///
	level(90) ///
     ylabel(none)  ///
	 xscale(range(-0.1 .)) xlabel(-0.1(0.1)0.53) ///
    graphregion(color(white)) bgcolor(white) ///
	yline(1.5, lcolor(gray%40) lpattern(line)) ///
	xtitle("Coefficient of carbon burden (log)")
graph export "${graph}/coef_esg_cb.png", replace as(png) name("Graph")


****************************
******Figure 3-Panel B******
****************************


global dataset sus kcgs msci ref
foreach j of global dataset {

use "${data}/cb_`j'_cleaned.dta", clear
egen ind_2digits=group(industry_group)
gen large=0
replace large=1 if firmsize=="대기업"
gen age2=age^2
gen age3=age^3
eststo `j': reg z_e lncb20 age age2 age3 i.ind_2digits i.large

}

coefplot ///
    (sus, label("Sustinvest")  msymbol(circle) mcolor("41 101 235") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("41 101 235") lwidth(medthick))) ///
    (msci, label("MSCI")  msymbol(circle) mcolor("21 164 74") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("21 164 74") lwidth(medthick))) ///
    (kcgs, label("KCGS") msymbol(circle) mcolor(orange) msize(medlarge) ///
    ciopts(recast(rcap) lcolor(orange) lwidth(medthick))) ///
    (ref, label("Refinitiv")     msymbol(circle) mcolor("124 58 237") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("124 58 237") lwidth(medthick))) ///
	, keep(lncb20) ylabel(, angle(vertical)) ///
	legend(pos(6) row(1)) ///
	xline(0) ///
	level(90) ///
     ylabel(none)  ///
	 xscale(range(-0.1 .)) xlabel(-0.1(0.1)0.53) ///
    graphregion(color(white)) bgcolor(white) ///
	yline(1.5, lcolor(gray%40) lpattern(line)) ///
	xtitle("Coefficient of carbon burden (log)")
graph export "${graph}/coef_e_cb.png", replace as(png) name("Graph")
	

	
****************************
******Figure 4-Panel A******
****************************


global dataset sus kcgs msci ref
foreach j of global dataset {

use "${data}/cb_`j'_cleaned.dta", clear
egen ind_2digits=group(industry_group)
gen large=0
replace large=1 if firmsize=="대기업"
gen age2=age^2
gen age3=age^3
summarize lncb20, detail
gen high_cb = (lncb20 > r(p75)) if !missing(lncb20)
eststo `j': reg z_esg lncb20 age age2 age3 i.high_cb c.lncb20#i.high_cb i.ind_2digits i.large

}

coefplot ///
    (sus, label("Sustinvest")  msymbol(circle) mcolor("41 101 235") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("41 101 235") lwidth(medthick))) ///
    (msci, label("MSCI")  msymbol(circle) mcolor("21 164 74") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("21 164 74") lwidth(medthick))) ///
    (kcgs, label("KCGS") msymbol(circle) mcolor(orange) msize(medlarge) ///
    ciopts(recast(rcap) lcolor(orange) lwidth(medthick))) ///
    (ref, label("Refinitiv")     msymbol(circle) mcolor("124 58 237") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("124 58 237") lwidth(medthick))) ///
	, keep(lncb20 1.high_cb#c.lncb20) ylabel(, angle(vertical)) ///
	legend(pos(6) row(1)) ///
	xline(0) ///
	level(90) ///
    rename(lncb20 = "CB" 1.high_cb#c.lncb20 = "CB × High GHG emissions") ///
    graphregion(color(white)) bgcolor(white) ///
	yline(1.5, lcolor(gray%40) lpattern(line))
graph export "${graph}/coef_esg_intensity.png", replace as(png) name("Graph")


****************************
******Figure 4-Panel B******
****************************


global dataset sus kcgs msci ref
foreach j of global dataset {

use "${data}/cb_`j'_cleaned.dta", clear
egen ind_2digits=group(industry_group)
gen large=0
replace large=1 if firmsize=="대기업"
gen age2=age^2
gen age3=age^3
summarize lncb20, detail
gen high_cb = (lncb20 > r(p75)) if !missing(lncb20)
eststo `j': reg z_e lncb20 age age2 age3 i.high_cb c.lncb20#i.high_cb i.ind_2digits i.large

}

coefplot ///
    (sus, label("Sustinvest")  msymbol(circle) mcolor("41 101 235") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("41 101 235") lwidth(medthick))) ///
    (msci, label("MSCI")  msymbol(circle) mcolor("21 164 74") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("21 164 74") lwidth(medthick))) ///
    (kcgs, label("KCGS") msymbol(circle) mcolor(orange) msize(medlarge) ///
    ciopts(recast(rcap) lcolor(orange) lwidth(medthick))) ///
    (ref, label("Refinitiv")     msymbol(circle) mcolor("124 58 237") msize(medlarge) ///
    ciopts(recast(rcap) lcolor("124 58 237") lwidth(medthick))) ///
	, keep(lncb20 1.high_cb#c.lncb20) ylabel(, angle(vertical)) ///
	legend(pos(6) row(1)) ///
	xline(0) ///
	level(90) ///
    rename(lncb20 = "CB" 1.high_cb#c.lncb20 = "CB × High GHG emissions") ///
    graphregion(color(white)) bgcolor(white) ///
	yline(1.5, lcolor(gray%40) lpattern(line))
graph export "${graph}/coef_e_intensity.png", replace as(png) name("Graph")
	
 

**********************
******Figure 5******
**********************


use "${data}/carbon_burden.dta", clear
preserve
collapse (sum) cb20_2100, by(industry_group)
replace cb20_2100 = cb20_2100 / 1000000000000
egen total = sum(cb20_2100)
gen share = round(cb20_2100 / total * 100, 0.1)
gsort -cb20_2100
gen rank = _n
gen n = _N
gen share_str = string(share, "%4.1f") + "%"
gen xpos = (_N - rank + 1) / _N * 100 - (100 / _N / 2)
levelsof rank, local(ranks)
local textcmd ""
foreach r of local ranks {
    qui sum cb20_2100 if rank == `r'
    local yval = r(mean)*1.02
    qui sum xpos if rank == `r'
    local xval = r(mean)
    qui levelsof share_str if rank == `r', local(s)
    local textcmd `"`textcmd' text(`yval' `xval' `s', size(vsmall) box margin(tiny) bcolor(none) lcolor(black) place(e))"'
}
graph hbar cb20_2100, over(industry_group, sort(1) descending lab(labsize(vsmall))) ///
    xsize(20) ysize(12) ///
    ylabel(, labsize(vsmall)) ///
    ytitle("Carbon burden (Trillions of KRW)", size(small)) ///
    bar(1, color(midgreen)) ///
    `textcmd' 
graph export "${graph}/cb_industry_cb.png", replace as(png) name("Graph")
restore

*****************************
******Table 3******
*****************************




*****************************
******Table A.4-Panel A******
*****************************

capture frame change default
capture frame drop results

frame create results str20 agency double(obs mean median sd min max)
local agencies "sus msci kcgs ref"
local labels   `" "Sustinvest" "MSCI" "KCGS" "Refinitiv" "'

local i = 1
foreach data of local agencies {
    use "${data}/cb_`data'_cleaned.dta", clear
	if "`data'" == "msci"  replace esg = esg * 10
    if "`data'" == "kcgs"  replace esg = esg * 100
    quietly summarize esg, detail
	
    local lab : word `i' of `labels'
    frame post results ("`lab'") (r(N)) (r(mean)) (r(p50)) ///
                       (r(sd)) (r(min)) (r(max))
    local ++i
}

local i = 1
foreach data of local agencies {
    use "${data}/cb_`data'_cleaned.dta", clear
	if "`data'" == "msci"  replace e = e * 10
    if "`data'" == "kcgs"  replace e = e * 100
    quietly summarize e, detail
	
    local lab : word `i' of `labels'
    frame post results ("`lab'") (r(N)) (r(mean)) (r(p50)) ///
                       (r(sd)) (r(min)) (r(max))
    local ++i
}

frame change results
format obs %4.0f
format mean median sd min max %5.1f

list, noobs clean


*****************************
******Table A.4-Panel B******
*****************************

use "${data}/carbon_burden.dta", clear


replace cb20_2100=cb20_2100/1000000000000
gen large=0
replace large=1 if firmsize=="대기업"
estpost summarize cb20_2100 age large, detail

* 화면 확인
esttab ., ///
    cells("count(fmt(0)) mean(fmt(1)) p50(fmt(1)) sd(fmt(1)) min(fmt(1)) max(fmt(1))") ///
    collabels("Obs" "Mean" "Median" "S.D." "Min" "Max") ///
    nonumber nomtitle noobs label

	
	



