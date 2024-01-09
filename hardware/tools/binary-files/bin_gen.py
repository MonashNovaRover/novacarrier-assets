f = open('test_24LC256.bin', 'wb')
f.write(b'\x0B')
f.seek(32767) # 128kB = 131071, 32kB = 32767 
f.write(b'\0')
f.close()