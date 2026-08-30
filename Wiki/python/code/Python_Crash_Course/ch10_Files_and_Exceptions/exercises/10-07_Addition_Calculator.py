# Purpose: Wrap your  code from Exercise  10-6 in a while  loop so the  user can
# continue entering numbers, even if they  make a mistake and enter text instead
# of a number.
#
# Reference: page 200 (paper) / 238 (ebook)

print("Give me two numbers, and I'll add them.")
print("Enter 'q' to quit.")

while True:
    first = input('First number: ')
    if first == 'q':
        break
    second = input('Second number: ')
    if second == 'q':
        break
    try:
        print(int(first) + int(second))
    except ValueError:
        print('Please, only input numbers.')

#     Give me two numbers, and I'll add them.
#     Enter 'q' to quit.
#     First number: 3
#     Second number: 5
#     8
#     First number: a
#     Second number: 5
#     Please, only input numbers.
