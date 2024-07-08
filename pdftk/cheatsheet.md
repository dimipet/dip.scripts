1 SHEET = 2 PAGES 

Split 60 page pdf / every 3 pages new file 

```
for((i=0;i<60;i+=3)); do pdftk 3h.pdf cat "$((i+1))"-"$((i+3))" output new_name_"$((i+1))"-"$((i+3))".pdf ; done 
```

36 page pdf with blank even pages. Split file Every 6 pages without blanks 
```
$ for((i=0;i<36;i+=6)); do pdftk 4h_1-36.pdf cat "$((i+1))" "$((i+3))" "$((i+5))" output 4h_1-36_"$((i+1))"-"$((i+3))"-"$((i+5))".pdf; done 
```

Other parts of document 
```
$ for((i=0;i<18;i+=6)); do pdftk 4h_53-70.pdf cat "$((i+1))" "$((i+3))" "$((i+5))" output 4h_53-70_"$((i+1))"-"$((i+3))"-"$((i+5))".pdf; done 

$ for((i=0;i<30;i+=6)); do pdftk 4h_79-108.pdf cat "$((i+1))" "$((i+3))" "$((i+5))" output 4h_7 _"$((i+1))"-"$((i+3))"-"$((i+5))".pdf; done 
```

16 page pdf. Every 4th page is blank. Split file Every 4 pages
```
for((i=0;i<16;i+=4)); do pdftk 4h_37-52.pdf cat "$((i+1))" "$((i+2))" "$((i+3))" output 4h_37-52_"$((i+1))"-"$((i+2))"-"$((i+3))".pdf; done 
```
