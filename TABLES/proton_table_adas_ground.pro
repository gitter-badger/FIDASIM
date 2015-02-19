pro proton_table_adas_ground
  print,'Calcuation of the proton table!'
  nmax=6        ;; number of quantum states
  maxeb=200.d0  ;; maximum energy in table [kev]
  maxti=20.d0   ;; maximum ion temperature in table [kev]         
  neb=1001      ;; table size
  nti=401       ;; table size


  ;; arrays of eb and ti
  ebarr=maxeb*(dindgen(neb)+0.5)/(neb-1.)
  tiarr=maxti*(dindgen(nti)+0.5)/(nti-1.)
  deb=ebarr[2]-ebarr[1]
  dti=tiarr[2]-tiarr[1]
  print,'energy min:', min(ebarr),'[kev]'
  print,'energy max:', max(ebarr),'[kev]'
  if min(ebarr) le 0.0 then begin
     print,'Minimum of ebarr must be larger than zero'
     stop
  endif
  print,'d-energy:', deb,'[kev/amu]'
  print,'ti min:', min(tiarr),'[kev]'
  print,'ti max:', max(tiarr),'[kev]'
  print,'d-ti:    ', dti,'[kev]'
  
  ab = 2.
  ai = 2.
  qp=replicate(0.,nmax+1,nmax,neb,nti)
  
  for ie=0,neb-1 do begin
     if ie mod 10 eq 0 then print, ie, ' of ',neb-1
     eb=ebarr[ie]
     for iti=0L,nti-1 do begin  
        ti=tiarr[iti]
        ;; Excitation and Deexcitation
        for n=0,nmax-2 do begin
           en = 13.6d-3*(1.-1./(n+1)^2)
           for m=n+1,nmax-1 do begin
              em=13.6d-3*(1.-1./(m+1)^2)
              de = em-en
              qp[m,n,ie,iti] = 0.0
              qp[n,m,ie,iti] = 0.0
           endfor
        endfor    
        ;; Impact ionization ;; Charge exchange
        for n=0,nmax-1 do begin 
           de = 13.6d-3/(n+1)^2
	   if n eq 0 then begin
             qp[nmax,n,ie,iti]= $
	      ;sigmav_piionization_adas_ground(ti/ai,eb/ab,n+1) $
              beam_therm_rate(ti,eb,ai,ab,de $
                              ,'sigma_piionization_adas_ground',param=[n+1]) $
              + beam_therm_rate(ti,eb,ai,ab,0.0 $
                              ,'sigma_cx_adas_ground',param=[n+1,-1])
	   endif		      
        endfor
     endfor
  endfor

  file='qptable_adas_ground.bin'
  openw, lun, file, /get_lun
  writeu,lun, long(nti)
  writeu,lun, double(dti)
  writeu,lun, long(neb)
  writeu,lun, double(deb) 
  writeu,lun, long(nmax)   
  writeu,lun, double(qp)
  close,lun
  free_lun, lun
  
  print, 'proton table written to:', file
    
  end 
