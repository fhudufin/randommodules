return function(s)c={}b={}i=1;p=1;for i=1,2048 do c[i]=0;end while(i<=#s)do x=s:sub(i,i)c[p]=x=="+"and c[p]+1 or x=="-"and c[p]-1 or c[p]p=x==">"and p+1 or x=="<" and p-1 or p;k=x=="."and io.write(string.char(c[p]))k=x=="["and table.insert(b,1,i);i=x=="]"and c[p] ~= 0 and table.remove(b,1) or i+1;c[p]=x==","and tonumber(io.read())or c[p] end end