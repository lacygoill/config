# What is a blob?

A sequence of bytes.

It mostly behaves like a list of numbers, where the numbers have an 8-bit value,
from 0 to 255.

##
# Creating
## How to create a blob?

Use  a `:let`  assignment,  write  your bytes  in  hexadecimal,  and prefix  the
sequence with `0z`.

    let blob = 0zFF00ED015DAF
    echo blob
    0zFF00ED01.5DAF˜
              │
              └ by default, Vim inserts a dot after every group of 4 bytes
                to improve readability

## How can I improve the readability of a blob, when I write an assignment?

You can insert a dot after any even number of hex characters.

    let blob = 0zFF00.ED01.5DAF
    let blob = 0zFF.00.ED.01.5D.AF
    echo blob
    0zFF00ED01.5DAF˜

---

Why an *even* number?
Probably because a byte needs two hex characters.
So, if you had an odd number of hex characters before/after a dot, it would mean
you've broken a byte.

## How can I read a blob from a binary file?

Use `readfile()` and the second optional argument `{type}` set to `B`:

    let blob = readfile($VIMRUNTIME.'/spell/en.ascii.spl', 'B')

##
# Getting
## How to get a byte in a blob?

Use its index inside square brackets after its name:

    let blob = 0z00112233

    let byte0 = blob[0]
    echo byte0
    0˜

    let byte2 = blob[2]
    echo byte2
    34˜

    let byte_last = blob[-1]
    echo byte_last
    51˜

### it doesn't match the original byte!

That's because it was converted in decimal.
Use `printf()` to convert it back in hexadecimal:

    let blob = 0z00112233
    let byte2 = blob[2]
    echo printf('%#x', byte2)
    0x22˜

    let blob = 0z00112233
    let byte_last = get(blob, -1)
    echo printf('%#x', byte_last)
    0x33˜

### how to avoid an error, if it doesn't exist?

Use `get()`:

    let blob = 0z00112233
    echo get(blob, 999)
    -1˜

    echo get(blob, 999, 1234)
    1234˜

###
## How to get a part of a blob?

Specify the first and last index, separated by a colon in square brackets:

    echo blob[i:j]

---

    let blob = 0z00112233
    let shortblob = blob[1:2]    " get 0z1122
    echo shortblob
    0z1122˜

    let blob = 0z00112233
    let shortblob = blob[2:-1]   " get 0z2233
    echo shortblob
    0z2233˜

You can omit  the first index to start  from 0, omit the last index  to go until
the end, or omit both to get a copy of the blob.

## How to iterate over the bytes of a blob?

Simply use a `:for` loop:

    let blob = 0zFF00ED015DAF
    let bytes_list = []
    for byte in blob
        let bytes_list += [byte]
    endfor
    echo bytes_list

## How to get a copy of a blob, with a different reference?  (2)

Use `copy()` or `[:]`:

    let blob = 0z001122
    let blob2 = blob[:]
    echo blob2 == blob
    1˜
    echo blob2 is# blob
    0˜

    let blob = 0z001122
    let blob2 = copy(blob)
    echo blob2 == blob
    1˜
    echo blob2 is# blob
    0˜

##
# Transforming
## How to concatenate two blobs?

Use the `+` or `+=` operator:

    echo blob1 + blob2

---

    let blob = 0z00112233
    let longblob = blob + 0z4455
    echo longblob
    0z00112233.4455˜

    let blob = 0z00112233
    let blob += 0z6677
    echo blob
    0z00112233.6677˜

## How to change the value of a range of consecutive bytes in a blob, with a single statement?

Use an assignment: in the LHS, use slicing; in the RHS, use a blob.

    let blob[i:j] = 0z....

---

    let blob = 0z00112233
    let blob[1:3] = 0z445566
    echo blob
    0z00445566˜

## How to remove a sequence of bytes from a blob?

Use `remove()`:

    call remove(blob, idx, end)

---

    let blob = 0z00112233
    call remove(blob, 2, -1)
    echo blob
    0z0011˜

## How to add a byte at the end of a blob?

Use `add()`:

    call add(blob, printf('%d', 0x123))

---

    let blob = 0z00112233
    call add(blob, printf('%d', 0x44))
    echo blob
    0z00112233.44˜

---

If you try to add several bytes, only the last one is used:

    let blob = 0z00112233
    call add(blob, printf('%d', 0x445566))
    echo blob
    0z00112233.66˜

Rationale:

A blob behaves like a list.
You can't use `add()`  to concatenate lists, so you can't  use it to concatenate
blobs either.

## How to insert a byte in a blob?

Use `insert()`:

    call insert(blob, 0x123)

---

    let blob = 0z00112233
    call insert(blob, 0xaa, 1)
    echo blob
    0z00AA1122.33˜

---

If you try to insert several bytes, it raises `E475`:

    let blob = 0z00112233
    call insert(blob, 0x4455, 1)
    E475: Invalid argument: 17493˜

## How to remove all the bytes `0x34` from a blob?

Use `filter()`:

    let blob = 0z12345678
    echo filter(blob, 'v:val != 0x34')
    0z125678˜

##
##
##
# Todo
## `ch_readblob()`

Document that a blob can be read from a channel with the `ch_readblob()` function.
