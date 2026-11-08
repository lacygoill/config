# conversion specifiers valid in `+FORMAT`
## `%%`

A literal "%".

## `%n`

A newline.

## `%t`

A horizontal tab.

##
## `%B`

Full month name (e.g. `January`).

---

For an abbreviated name, use `%b` (e.g. `Jan`).

## `%N`

Nanoseconds (`000000000..999999999`).

## `%z`

Numeric time zone (e.g. `-0400`).

Some variants are also supported:

   - `%:z`: `+hh:mm` (e.g. `-04:00`)
   - `%::z`: `+hh:mm:ss` (e.g. `-04:00:00`)
   - `%:::z`: the correction is shortened to the maximum (`+hh` or `+hh:mm` or `+hh:mm:ss`)

---

For an alphabetic time zone abbreviation, use `%Z` (e.g. `EDT`).

##
## `%Y`, `%m`, `%d`

year, month, day of month

## `%H`, `%M`, `%S`

hour, minute, second

## `%s`

Seconds since Unix epoch.

#
# optional flags valid in conversion specifiers

Numeric fields  are normally padded  with zeros,  so that, for  example, numeric
months are always  output as two digits.   Seconds since the Unix  epoch are not
padded, though, since there is no natural width for them.

## `-`

Suppress padding; useful if the output is intended for human consumption.

                             v   v
    $ date --date='Feb 1' +'%-d/%-m'
    1/2
    ^^^
    no padding of 0s

## `_`

Pad with spaces; useful if you need  a fixed number of characters in the output,
but zeros are too distracting.

                             v   v
    $ date --date='Feb 1' +'%_d/%_m'
     1/ 2
    ^  ^

## `^`

Use upper case characters if possible.

## field width

Not  a flag,  but an  optional number  which  can be  used (after  any flag,  if
present) to  specify a field  width.  If the  output field has  fewer characters
than the  specified number, the result  is written right adjusted  and padded to
the given width.  For  example, `%9B` prints the right adjusted  month name in a
field of width 9:

    $ date --date='1970-01-01' +'|%9B|'
    |  January|

##
# `--date`'s argument

It's a mostly free format human readable "date string".

Here are some examples:

   - `2 months ago`
   - `3 months 1 day`: 3 months and 1 day in the future
   - `25 Dec`: 25th of December, this year
   - `1970-01-01 00:00:00`: Unix epoch local timezone (*)
   - `1970-01-01 00:00:00 +0000`: Unix epoch UTC
   - `1970-01-01 3600 seconds UTC`: 1 hour after Unix epoch

(*) As it  was at the time given.   For example, at the time of  the Unix epoch,
`Europe/Paris` was 1 hour ahead of UTC:

    $ date --date='1970-01-01 00:00:00' +'%s'
    3600
    ^--^
    number of seconds in 1 hour

When it was midnight in Greenwich, it was already 1 a.m. in Paris.

If you want your  date string to be considered relative to UTC  (and `$TZ` to be
ignored), append `+0000` or `UTC`.

## The calendar date is typically expressed as `YEAR-MONTH-DAY` (ISO 8601).

For  example,  `1972-09-24`.   But other  specifications  exist  (non-exhaustive
list):

    72-09-24       # If the year is below 100, it's assumed to be in the 19th or 20th century.
                   # 20th for 00 through 68.
                   # 19th for 69 through 99.

    9/24/1972      # common U.S. writing

    24 September 1972

    24 Sept 1972   # September has a special abbreviation
    24 Sep 1972    # three-letter abbreviations are always allowed

    Sep 24, 1972

## The time of day can be given as either:

   - `HOUR:MINUTE`
   - `HOUR:MINUTE:SECOND`
   - `HOUR:MINUTE:SECOND.fraction`
   - `HOUR[:MINUTE[:SECOND[.fraction]]] {am|pm}`

If the time is followed by `am` or `pm`, `HOUR` is restricted to run from `1` to
`12`. They  indicate resp.  the first  and second  half of  the day.   `12am` is
midnight; `12pm` is noon.

The  time can  be  followed by  a  time zone  correction/item.   Unless it  uses
`am`/`pm`, in which  case only a time  zone item (e.g. `CET`) can  follow; not a
time zone correction (like `+0100`).

Here are some examples, all of which represent the same time:

    20:02:00.000000
    20:02
    8:02pm
    20:02-0500  # in EST (U.S. Eastern Standard Time)

## A few ordinal numbers (like `first`, `next`) can be written out in words in some contexts.

This is  most useful for  specifying day of  the week items  (`third monday`) or
relative items  (e.g. `last month`).  Among  the most commonly used  are ordinal
numbers:

   - `last` (-1)
   - `this` (0)
   - `first`/`next` (1)
   - `third` (3)
   ...
   - `twelfth` (12)

There is no word for the ordinal number `2`, because `second` already stands for
a unit of time.

## A day of the week forward the date (if necessary) to reach that day of the week in the future.

It can  be preceded by  an ordinal number,  to move forward  supplementary weeks
(e.g. `3 monday` or `third monday`).

Alternatively, it can be preceded by `this`, which doesn't move time, but simply
emphasizes that the day belongs to the  current week (or the next one, whichever
comes first in the future).   For example, `this thursday`, `next thursday`, and
`thursday` all mean the same thing.

## A relative item adjusts a date (or the current date if none) forward or backward.

Some examples are `1 day` and `2 years ago`.

---

The unit of time displacement can be:

   - `year`
   - `month`
   - `fortnight` (14 days)
   - `week`
   - `day`

   - `today`/`now` (0-valued time displacement; can be used to stress another
     item, like in `12:00 today`)

   - `tomorrow`
   - `yesterday`
   - `hour`
   - `minute`
   - `sec[ond]`

An `s` suffix on these units is accepted and ignored.

---

The unit of time can be preceded  by a multiplier, given as an optionally signed
number.   Following  a relative  item  by  the  string  `ago` is  equivalent  to
preceding the unit by a multiplier with value `-1`.

---

The effects of relative items accumulate:

                              v------v v-----v v---v
    $ date --date='1970-01-01 3 months 2 weeks 1 day' --utc
    Thu 16 Apr 1970 12:00:00 AM UTC
        ^----^

##
## An empty date string means the beginning  of today (i.e. midnight).

## `@NUMBER` stands for a count of seconds since the Unix epoch.

`@0` represents  the Unix epoch,  `@1` one second after  the Unix epoch,  and so
forth.   Negative counts  are supported,  so  that `@-1`  represents one  second
before the Unix epoch.

`NUMBER` can contain a decimal point.

## `DST` can be used in a time zone item.

To specify the daylight saving time zone corresponding to a given *non* daylight
saving time zone:

                              v-----v
    $ date --date='1970-06-01 CET DST' --utc
    Sun 31 May 1970 10:00:00 PM UTC

                              v--v
    $ date --date='1970-06-01 CEST' --utc
    Sun 31 May 1970 10:00:00 PM UTC

Notice how `CET DST` gives the same output as `CEST`.

## Comments are supported (between parentheses).

                   v----v            v--------v
    $ date --date='(some) 1970-01-01 (comments)'
    Thu 01 Jan 1970 12:00:00 AM CET
