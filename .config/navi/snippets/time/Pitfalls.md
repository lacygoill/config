# `date(1)`
## Sometimes, a relative item (e.g. `-N months`) gives a wrong date!

                        vv    v------v
    $ date --date='2000-03-31 -1 month' +'%B'
    March
    # expected: February

There is no  day 31 in February, so  `date(1)` falls back on the  next day after
the last one of February, which is day 1 in March.

The underlying issue  is that a month is  a fuzzy unit of time.   Not all months
last the same number of days.

As a workaround, re-set your date to the middle of the month:

                           vv
    $ date --date='2000-03-15 -1 month' +'%B'
    February

All months last at least 15 days.

## After a relative item, a numeric time zone correction (e.g. `+0000`) is not valid.

For example, `2 months ago` or `3600 seconds`:

    1970-01-01 3600 seconds +0000
                            ^---^
                              ✘

If that's an issue, use a time zone item (e.g. `UTC`):

    1970-01-01 3600 seconds UTC
                            ^^^
                             ✔

## Don't conflate `+0000`/`UTC` (inside the date string) with `--utc` (outside).

`--utc` is for  both the input date  string (!) *and* the  formatted output date
and time.  `+0000` and `UTC` are only for the input date string; the output date
and time is still relative to your `$TZ`.

(!) Actually,  if the  input date  string contains  a time  zone correction/item
other than  `+0000`/`UTC`, it  overrides `--utc`  (for the  input date,  not the
output).  Basically, `--utc` is as if your `TZ` was set to `UTC0`.  Your `TZ` is
only read when there is no explicit time zone correction/item.

## The output of `date(1)` is not always acceptable as a date string.

First, only English is supported for the day of the week, and the month.
Second, there is no standard meaning for time zone items like `IST`.

So, if you run  `date(1)` to output a date string which you  intend to give back
as input to `date(1)`  later, then specify a date format  that is independent of
language (`LC_ALL=C`)  and that does not  use time zone items  other than `UTC`.
For example:

    $ date --rfc-3339=seconds
    2004-02-29 16:21:42-08:00

    $ date +'%Y-%m-%d %H:%M:%S %z'
    2004-02-29 16:21:42 -0800

    $ date +'@%s.%N'
    @1078100502.692722128

    $ LC_ALL=C TZ=UTC0 date
    Mon Mar  1 00:21:42 UTC 2004
