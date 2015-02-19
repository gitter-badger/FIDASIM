PRO neuttable_adas_ground
 
  nmax=6
  maxeb=200.d0  ;; maximum energy in table [kev/amu]        
  neb=2001      ;; table size   
  
  ;; energy array
  ebarray=maxeb*(dindgen(neb)+0.5)/(neb-1.)
  deb=ebarray[2]-ebarray[1]
  print,'energy min:', min(ebarray),'[kev/amu]'
  print,'energy max:', max(ebarray),'[kev/amu]'
  if min(ebarray) le 0.0 then begin
     print,'Minimum of ebarray must be larger than zero'
     stop
  endif
  print,'d-energy:', deb,'[kev/amu]'
  
  sigma=replicate(0.,nmax,nmax,neb)
  for n=0,nmax-1 do begin
     for m=0,nmax-1 do begin
         sigma[m,n,*]= sigma_cx_adas_ground(ebarray,n+1,m+1)   	    
     endfor
  endfor

  ;; write the cross sections into a file
  file='neuttable_adas_ground.bin'
  openw, lun, file, /get_lun
  writeu,lun, long(neb)
  writeu,lun, double(deb) 
  writeu,lun, long(nmax) 
  for ie=0L,neb-1 do begin 
     for n=0,nmax-1 do begin
        for m=0,nmax-1 do begin
              if n eq 0 and m eq 0 then begin
	         writeu, lun, double(sigma[m,n,ie]);cm^2
	      endif else writeu, lun, double(0.0)	 
        endfor
     endfor
  endfor
  close,lun
  free_lun, lun
  print, 'neutralization rate table written to:', file
end
