import os

filename = 'TPS25750_test_file.bin' # file in current directory, note this program will modify the original file
target_size = 32768 # in bytes
append_char = b'\xFF'

print(f'\nfilename: {filename}')
print(f'target file size: {target_size} bytes')
print(f'append character: {append_char}\n')

try: 
    print(f'Opening {filename}...')
    f = open(filename, 'ab')
    fsize = os.path.getsize(filename)
except OSError:
    print(f'\nERROR! {filename} does not exist or is inaccessible\n')
else:
    print(f'Found {filename} of size {fsize} bytes')

    if target_size < fsize:
        print('\nERROR! File size exceeds target file size\n')
    else:
        print(f'Appending {target_size - fsize} bytes to {filename}...')

        for i in range(target_size - fsize):
            f.write(append_char)

        print(f'\nSUCCESS! {filename} is now of size {os.path.getsize(filename)} bytes\n')    
        # f.seek(32767) # 128kB = 131071, 32kB = 32767 
        # f.write(b'\0')
       
    f.close()