return function(s)d={}b={}i=1;p=1;for i=1,2048 do d[i]=0;end while(i<=#s)do x=s:sub(i,i)d[p]=x=="+"and d[p]+1 or x=="-"and d[p]-1 or d[p]p=x==">"and p+1 or x=="<" and p-1 or p;k=x=="."and io.write(string.char(d[p]))k=x=="["and table.insert(b,1,i);i=x=="]"and d[p] ~= 0 and table.remove(b,1) or i+1;d[p]=x==","and tonumber(io.read())or d[p] end end
