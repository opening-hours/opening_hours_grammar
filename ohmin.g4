grammar ohmin;

// Basic elements
// Trivial stuff, prefixed with 'c' and should never change during grammar development
// Note: case SENSITIVE

c247string     : '24/7';

FIRSTTENWITHOUTLEADINGZEROS: '0'..'9';
FIRSTTENWITHLEADINGZEROS   : '0' FIRSTTENWITHOUTLEADINGZEROS;

cminute        : FIRSTTENWITHLEADINGZEROS | FIRSTTENWITHOUTLEADINGZEROS | '10' | '11' | '12' | '13' | '14' | '15' | '16' | '17' | '18' | '19' | '20' | '21' | '22' | '23' | '24' | '25' | '26' | '27' | '28' | '29' | '30' | '31' | '32' | '33' | '34' | '35' | '36' | '37' | '38' | '39' | '40' | '41' | '42' | '43' | '44' | '45' | '46' | '47' | '48' | '49' | '50' | '51' | '52' | '53' | '54' | '55' | '56' | '57' | '58' | '59';
chour          : FIRSTTENWITHLEADINGZEROS | FIRSTTENWITHOUTLEADINGZEROS | '10' | '11' | '12' | '13' | '14' | '15' | '16' | '17' | '18' | '19' | '20' | '21' | '22' | '23' | '24';

/* daynum */
cday           : FIRSTTENWITHLEADINGZEROS | FIRSTTENWITHOUTLEADINGZEROS | '10' | '11' | '12' | '13' | '14' | '15' | '16' | '17' | '18' | '19' | '20' | '21' | '22' | '23' | '24' | '25' | '26' | '27' | '28' | '29' | '30' | '31';

/* wday */
cdayoftheweek     : cworkdays | cweekend; // Unnecessary overcomplication, mainly for richer stats

cworkdays         : cworkdays2letters | cworkdays3letters;
cworkdays2letters : 'Mo'  | 'Tu'  |' We'  | 'Th'  | 'Fr';
cworkdays3letters : 'Mon' | 'Tue' |' Wed' | 'Thu' | 'Fri';

cweekend         : cweekend2letters | cweekend3letters;
cweekend2letters : 'Sa'  | 'Su';
cweekend3letters : 'Sat' | 'Sun';

cweeknum       : FIRSTTENWITHLEADINGZEROS | FIRSTTENWITHOUTLEADINGZEROS | '10' | '11' | '12' | '13' | '14' | '15' | '16' | '17' | '18' | '19' | '20' | '21' | '22' | '23' | '24' | '25' | '26' | '27' | '28' | '29' | '30' | '31' | '32' | '33' | '34' | '35' | '36' | '37' | '38' | '39' | '40' | '41' | '42' | '43' | '44' | '45' | '46' | '47' | '48' | '49' | '50' | '51' | '52' | '53';

// Is it possible to allow numeric monthss?
cmonth         : 'Jan' | 'Feb' | 'Mar' | 'Apr' | 'May' | 'Jun' | 'Jul' | 'Aug' | 'Sep' | 'Oct' | 'Nov' | 'Dec';

/* event */
// TODO: review moveable_holidays
// TODO: review variable_time
csunlightevent : 'dawn' | 'sunrise' | 'sunset' | 'dusk';

/* extended hour */
// TODO test against values in database, adjust
cwrappinghour  : FIRSTTENWITHLEADINGZEROS | FIRSTTENWITHOUTLEADINGZEROS | '10' | '11' | '12' | '13' | '14' | '15' | '16' | '17' | '18' | '19' | '20' | '21' | '22' | '23' | '24' | '25' | '26' | '27' | '28' | '29' | '30' | '31' | '32' | '33' | '34' | '35' | '36' | '37' | '38' | '39' | '40' | '41' | '42' | '43' | '44' | '45' | '46' | '47' | '48';

/* plus_or_minus */
coffsetsymbols: '+' | '-';

//
// Non-trivial rules below
//
NON_ZERO_DIGIT   : '1'..'9';
DIGIT            : '0' | NON_ZERO_DIGIT;

positive_integer          : NON_ZERO_DIGIT DIGIT*; //not sure if it is faster than '1'..'9' | '1'..'9'('0'..'9')+
negative_integer          : '-' NON_ZERO_DIGIT DIGIT*; //duplication on purpose: negative_integer is not subtype of positive_integer

//hh_mm         : DIGIT DIGIT ':' DIGIT DIGIT;
hh_mm           : chour ':' cminute;

/* extended_hour_minutes */
wrapping_hh_mm : cwrappinghour ':' cminute;


COMMENT             : '"' ~('"')+? '"'; //Allow or restrict empty comments?
COMMENT_EMPTY       : '""';
comment             : COMMENT | COMMENT_EMPTY;

nth_entry           : negative_integer | positive_integer | positive_integer'-'positive_integer;


// TODO decide what to do with ws/WS
ws : (' ' | '\t' | '\n')*?;
//WS : [' ' | '\t' | '\n']+ -> channel(HIDDEN);

//
// TOP-level rule and actual grammar below
//
// https://github.com/antlr/antlr4/blob/master/doc/
// https://github.com/antlr/antlr4/blob/master/doc/parser-rules.md
//
// status: WIP
// week 4-16 We 00:00-24:00; week 38-42 Sa 00:00-24:00; PH off
// TODO unprocessed input below
// 2013,2015,2050-2053,2055/2,2020-2029/3,2060+ Jan 1
// week 2-52/2 We 00:00-24:00; week 1-53/2 Sa 00:00-24:00; PH off
// 2012 easter -2 days-2012 easter +2 days: open "Around easter"; PH off
// Jan 23-Feb 11,Feb 12 00:00-24:00; PH off
// Mo-Fr 08:00-12:00, We 14:00-18:00; Su,PH off


time_domain   : rule_sequence (any_rule_separator rule_sequence)*;
rule_sequence :
                selector_sequence /* If no rule_modifier is specified, then the rule_sequence is interpreted as open. */
//              | rule_modifier // TODO: is this possible?
              | selector_sequence ws rule_modifier;

    //
    // Rule separators
    // status: done, untested
    any_rule_separator        :
                                normal_rule_separator
//                              | additional_rule_separator // TODO: "Mo, Tu, Th, Fr 12:00-18:00; Sa, PH 12:00-17:00; Th[3],Th[-1] off"
                              | fallback_rule_separator;

    normal_rule_separator     : ';' ws;
//    additional_rule_separator : ',' ws;
    fallback_rule_separator   : ' || ';

    //
    // Rule modifiers
    // status: done, untested
    rule_modifier             :
                                rule_modifier_empty
                              | rule_modifier_open
                              | rule_modifier_closed
                              | rule_modifier_unknown
                              | rule_modifier_comment
                              ;
    rule_modifier_empty       : '';                                   // TODO defaults to 'open'
    rule_modifier_open        : ('open') (ws comment)?;              // TODO 'opened'
    rule_modifier_closed      : ('closed' | 'off') (ws comment)?;    // TODO 'closed'
    rule_modifier_unknown     : ('unknown') (ws comment)?;           // TODO 'unknown'
    rule_modifier_comment     : comment;                              // TODO defaults to 'unknown'


//
// Selectors
// status: done, untested
selector_sequence     :
                        c247string
                      | small_range_selectors
                      | wide_range_selectors
                      | wide_range_selectors ws small_range_selectors;
small_range_selectors :
                        weekday_selector
                      | weekday_selector ws time_selector // spec says both are required (only this case), but this is not true in practice
                      | time_selector
                      ;

    //
    // Weekday selector (red)
    // status: done, untested
    weekday_selector     :
                           weekday_sequence
                         | holiday_sequence
                         | holiday_sequence ws ',' ws weekday_sequence
                         | weekday_sequence ws ',' ws holiday_sequence
                         ; // any semantic difference between ', ' and ' '?
    weekday_sequence     : weekday_ranges (',' ws weekday_ranges)*;
    weekday_ranges        : weekday_ranges_single | weekday_ranges_range | weekday_ranges_range_nth | weekday_ranges_range_nth_offset;
    weekday_ranges_single : cdayoftheweek;
    weekday_ranges_range  : cdayoftheweek '-' cdayoftheweek;

    /**
     * Su represents all Sundays,
     * Su[1]  - first Sunday of a month,
     * Su[-1] -  last Sunday of a month.
     */
    weekday_ranges_range_nth        : cdayoftheweek '[' nth_entry (',' nth_entry)* ']';
    weekday_ranges_range_nth_offset : cdayoftheweek '[' nth_entry (',' nth_entry)* ']' day_offset;

    holiday_sequence     : holiday (',' holiday)*;
    holiday              :
                           singular_day_holiday (ws day_offset ws)? // Only a day shift around one day (В± 1 day) is currently defined.
                         | plural_day_holiday
                         ;

    singular_day_holiday : 'PH'; // https://github.com/opening-hours/opening_hours.js#holidays
    plural_day_holiday   : 'SH';


    day_offset           : (( '+' positive_integer) | (negative_integer)) ws ('day' 's'?);


    //
    // Time selector (blue)
    // status: done, untested
    time_selector            : timespan (',' timespan)*;

    timespan                 :
//                             timespan_simple | // This is only valid in point in time mode (tags like collection_times=*)
                             timespan_openended
                             | timespan_range
                             | timespan_range_openended
//                             | timespan_case_everyNminutes
//                             | timespan_case_everyPeriod
                             ;
//    timespan_simple          : time;
    timespan_openended       : time '+';

    // Ambiguities here?
    timespan_range           : time '-' (time | wrapping_hh_mm);
    timespan_range_openended : time '-' (time | wrapping_hh_mm) '+';

    /**
    This notation describes a repeated event:

    10:00-16:00/90 and 10:00-16:00/1:30 are evaluated as "from ten am to four pm every 1ВЅ hours".
    Especially departure times can be written very concise and compact using this notation.
    The interval time following the "/" is valid but ignored for opening_hours.

    This is only valid in point in time mode (tags like collection_times=*.
    */
//    timespan_case_everyNminutes : time '-' (time | wrapping_hh_mm) '/' cminute;
//    timespan_case_everyPeriod   : time '-' (time | wrapping_hh_mm) '/' hh_mm;

    time                     : hh_mm | variable_time;
//    extended_time            : time | wrapping_hh_mm;
    variable_time            : csunlightevent | csunlightevent coffsetsymbols hh_mm;

wide_range_selectors  :
    ( //TODO: review combinations below
      year_selector
    | monthday_selector
    | week_selector
    | year_selector monthday_selector
    | year_selector monthday_selector week_selector
    | year_selector week_selector
    | monthday_selector week_selector
    ) ':'? |
    comment (':')?
    ;

    //
    // Year selector (Orange)
    // status: done, untested

    year_selector                  : year_selector_single | year_selector_range | year_selector_single_openended | year_selector_range_special;
    year_selector_range            : year_selector_single '-' year_selector_single;
    year_selector_range_special    : year_selector_range '/' positive_integer;

    /* year */
    year_selector_single           : ('19' DIGIT  DIGIT ) | ('20' DIGIT DIGIT );
    year_selector_single_openended : year_selector_single '+';

    //
    // Month selector
    // status: done, untested

    monthday_selector             : monthday_range (',' monthday_range)*;

    monthday_range                :
                                    monthday_range_one
                                  | monthday_range_range
                                  | monthday_range_cron
                                  | monthday_range_from
                                  | monthday_range_from_openended
                                  | monthday_range_from_to
                                  ;
    monthday_range_one            : year_selector_single? cmonth;
    monthday_range_range          : year_selector_single? cmonth '-' cmonth;
    monthday_range_cron           : year_selector_single? cmonth '-' cmonth  '/' positive_integer;
    monthday_range_from           : date_from;
    monthday_range_from_openended : date_from date_offset? '+';
    monthday_range_from_to        : date_from date_offset? '-' date_to date_offset?;


						  /**
                            *  Given any calendar day:
                            * +Su - selects the first Sunday after this calendar day
                            * -Su - selects the last Sunday before this calendar day. 
                           */
    date_offset          :
                           coffsetsymbols cdayoftheweek
                         | day_offset
                         ;

    date_from            :
                           year_selector_single? cmonth cday
                         | year_selector_single? moveable_holidays
                         ;
    date_to              : date_from | cday;

    /* See https://en.wikipedia.org/wiki/Category:Moveable_holidays */
    /* variable_date */
    moveable_holidays    : 'easter';

    //
    // Calendar week selector (Yellow)
    // status: done, untested
    week_selector        : 'week ' week (',' week)*;
    week                 : week_simple | week_range | week_range_cron;
    week_simple          : cweeknum;
    week_range           : cweeknum '-' cweeknum;
    week_range_cron      : cweeknum '-' cweeknum '/' positive_integer;
