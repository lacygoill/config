# `date(1)`
## time zone correction

It can follow a time, and should be expressed as one of:

   - `SHH:MM`
   - `SHHMM`
   - `SHH`
   - `SH`

Where `S` is a sign (`+`/`UTC` or `-`), `HH` is a number of zone hours, and `MM`
is a number of zone minutes.

It forces interpretation of the time relative to UTC.

For example, `+0530` and  `+05:30` both stand for the time  zone 5.5 hours ahead
of UTC (e.g. India).  The maximum zone correction is 24 hours.

## time zone item

An alphabetic  time zone abbreviation  (as opposed to  a numeric offset)  can be
obtained with `date(1)`'s `%Z` conversion specifier:

    $ date +'%Z'
    CEST

Time  zone  items  other  than  `UTC`  and  `Z`  are  obsolescent  and  are  not
recommended,  because they  are ambiguous;  for example,  `EST` has  a different
meaning in  Australia than in  the United States.   Instead, it's better  to use
unambiguous numeric time zone  corrections like `-0500`.  Unfortunately, they're
still widely  used, so  the present glossary  tries to define  some of  the most
popular ones.

### CET / EST / CST / PST

Central European Time (Paris)
Eastern Standard Time (New York)
Central Standard Time (Chicago)
Pacific Standard Time (Los Angeles)

Those are when DST is *not* in effect; i.e. in winter.

---

`CST` might also mean "China Standard Time":

    $ TZ=Asia/Shanghai date +'%Z' \
      ; TZ=Asia/Taipei date +'%Z'
    CST
    CST

### CEST / EDT / CDT / PDT

Central European Summer Time (Paris)
Eastern Daylight Time (New York)
Central Daylight Time (Chicago)
Pacific Daylight Time (Los Angeles)

Those are when DST is in effect; i.e. in summer.

### JST / KST

Japan Standard Time
Korea Standard Time

It seems that Asian countries don't use DST.

###
### DST

Daylight Saving Time

It's not a  time zone, but a positive  offset applied to the local  time in some
countries, in summer.

### TAI

International Atomic Time

Computed  from  UTC  by  applying  corrections   as  given  in  the  table  from
`/usr/share/zoneinfo/leap-seconds.list`.

### UTC / GMT

Coordinated Universal Time

Established in 1960, it's the primary time standard by which the world regulates
clocks and time.

   > The UTC time scale is realized by many national
   > laboratories and timing centers. Each laboratory
   > identifies its realization with its name: Thus
   > UTC(NIST), UTC(USNO), etc. The differences among
   > these different realizations are typically on the
   > order of a few nanoseconds (i.e., 0.000 000 00x s)
   > and can be ignored for many purposes. These differences
   > are tabulated in Circular T, which is published monthly
   > by the International Bureau of Weights and Measures
   > (BIPM). See www.bipm.org for more information.

Source: `/usr/share/zoneinfo/leap-seconds.list`

---

There is no time  difference between GMT (Greenwich Mean Time)  and UTC; and for
historical reasons, UTC is  often called GMT.  That said, the  GMT time scale is
no longer used, and the use of GMT to designate UTC is discouraged.
