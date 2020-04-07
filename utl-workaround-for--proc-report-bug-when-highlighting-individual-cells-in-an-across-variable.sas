Workaround for a  proc report bug when highlighting individual cells in a across variable

Problem: Set bacground color to yellow for an Counttry that have popAGR over 3%

I have limited the number of countries in sashelp.demographics for documentation purposes.

Shold work for full data.

github
https://tinyurl.com/sbzox85
https://github.com/rogerjdeangelis/utl-workaround-for--proc-report-bug-when-highlighting-individual-cells-in-an-across-variable

This solution uses the very powerfull array macro by
Bartosz Jablonski
yabwon@gmail.com
see
https://github.com/yabwon/SAS_PACKAGES


macros (barray and bdo_over see Bart for latest versions)
https://tinyurl.com/y9nfugth
https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories

SAS forum
https://tinyurl.com/v4rnkf6
https://communities.sas.com/t5/New-SAS-User/How-do-I-apply-conditional-formatting-in-Proc-Report-to-an-quot/m-p/638127

THIS WORKS

     proc report data=sashelp.class nowd ;
     cols weight;
     define weight / display style(column)={ background=cback.};
     run;quit;

THIS DOES NOT WORK TO COLOR BACKGROUND YELLOW (BUG)

   Here is the bug. The format will not color the cell.

     define name / across 'name' ORDER=DATA;
     define Pop / analysis SUM 'Pop' missing;
     define PopAGR / analysis SUM 'PopAGR' missing  style(column)= {background=cback.};

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
   set sashelp.demographics(keep=region name Pop PopAGR
        where=(name in ( 'LIBERIA', 'KENYA', 'CHAD','CHILE','CUBA','PERU')));
run;quit;

WORK.HAVE total obs=6                       | RULES
                                            |
  NAME       REGION       POP       POPAGR  |
                                            |
  CUBA        AMR      11269400    0.003427 |
  CHILE       AMR      16295102    0.011407 |
  PERU        AMR      27968244    0.014628 |
  CHAD        AFR       9748931    0.029949 |
  KENYA       AFR      34255722    0.020855 |
                                            |
  LIBERIA     AFR       3283267    0.042296 | Liberia is > .03
 ..                                [Yellow}   so color it yellow

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

d:/xls/yellow.xlsx

CELL M2 is Yellow because it is greater than 3%

    |-----------------------------------------------------------------------------------------------------------------------------------------|
    |  A   |      B     |   C   |     D      |   E   |     F      |   G   |   H      |   I   |       J    |   K   |       L    |   M          |
    |------+------------+-------+------------+-------+------------+-------+----------+-------+------------+-------+------------+--------------|
    |                 CUBA                 CHILE                PERU               CHAD                 KENYA               LIBERIA           |
 1  |Region         Pop  PopAGR          Pop  PopAGR          Pop  PopAGR        Pop  PopAGR          Pop  PopAGR          Pop  PopAGR        |
    |-----------------------------------------------------------------------------------------------------------------------------------------|
 2  |AFR   |           .|  .    |           .|  .    |           .|  .    | 9,748,931|  3.0% |  34,255,722|  2.1% |   3,283,267|  4.2% YELLOW |**
    |------+------------+-------+------------+-------+------------+-------+----------+-------+------------+-------+------------+--------------|
 3  |AMR   |  11,269,400|  .34% |  16,295,102|  1.1% |  27,968,244|  1.5% |         .|  .    |           .|  .    |           .|  .           |
    ------------------------------------------------------------------------------------------------------------------------------------------

 *
 _ __  _ __ ___   ___ ___  ___ ___
| '_ \| '__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
;


* get then number of _c#_ variavles to check.;
proc sql;
    select count(distinct name) into :fat from have;
run;quit;
/*
%put &=fat;
faf=6
*/

* create a macro array f to generate the odd  _c#_ variables;
* you need barray not array macro;

%barray(f[1:6], function = (2*_I_)+1 )
FLBOUND 1%put &=fLBOUND. &=fHBOUND. &=fN.;
FHBOUND 6
%put _user_;

/*
*These are the _c#_ variables that contain the popARG across variables;

GLOBAL F1 3   _c3_ has cuba popAGR    (even _c#_ have pop variables)
GLOBAL F2 5   _c5_ has chile popAGR
GLOBAL F3 7   ...
GLOBAL F4 9
GLOBAL F5 11
GLOBAL F6 13  _c13+ has Liberia popAGR
*/


%utlfkil(d:/xls/yellow.xlsx);

ods excel file="d:/xls/yellow.xlsx" style=pearl options (
         sheet_name                 = "yellow"
         gridlines                  = 'yes'
         tab_color                  = "yellow"
         autofilter                 = 'yes'
         orientation                = 'landscape'
         zoom                       = "150"
         suppress_bylines           = 'no'
         embedded_titles            = 'yes'
         embedded_footnotes         = 'yes'
         embed_titles_once          = 'yes'
         frozen_headers             = 'Yes'
         frozen_rowheaders          = 'yes'
        );
proc report data=have FORMCHAR='|----|+|---+=|-/\<>*' box ;
     column region (name, (Pop PopAGR));
     define name   / across 'name' ORDER=DATA;
     define Pop    / analysis SUM 'Pop' missing width=11;
     define PopAGR / analysis SUM 'PopAGR' missing width=6;
     define region / group 'region' missing;
     compute PopAgr;
         %do_over(f,phrase=%str(if _c?_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' );));
     endcomp
run;quit;
ods excel close;


* if you want the generated code

data _null_;
 put
  %do_over(f,phrase=
      "if _c?_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' )" /)
  ;
run;quit;



if _c3_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' )
if _c5_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' )
if _c7_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' )
if _c9_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' )
if _c11_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' )
if _c13_ ge .03 then CALL DEFINE( _COL_,'STYLE','STYLE={BACKGROUND=yellow}' )

