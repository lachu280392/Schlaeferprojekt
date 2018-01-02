file_id = fopen('oct/p1m1.bin');
oct = fread(file_id, [512, 108900], 'float');
image(oct)
