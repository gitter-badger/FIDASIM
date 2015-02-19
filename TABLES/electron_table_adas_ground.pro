pro electron_table_adas_ground
  nmax=6
  
  maxeb=200.d0  ;; maximum energy in table [kev]
  maxte=20.d0   ;; maximum electron temperature in table [kev]         
  neb=1001      ;; table size
  nte=401       ;; table size

  ;; arrays of eb and ti
  ebarr=maxeb*(dindgen(neb)+0.5)/(neb-1.)
  tearr=maxte*(dindgen(nte)+0.5)/(nte-1.)
  deb=ebarr[2]-ebarr[1]
  dte=tearr[2]-tearr[1]
  print,'energy min:', min(ebarr),'[kev]'
  print,'energy max:', max(ebarr),'[kev]'
  if min(ebarr) le 0.0 then begin
     print,'Minimum of ebarr must be larger than zero'
     stop
  endif
  print,'d-energy:',deb,'[kev]'
  print,'te min:', min(tearr),'[kev]'
  print,'te max:', max(tearr),'[kev]'
  print,'d-te    :',dte,'[kev]' 

  ab = 2.
  ame = 9.109d-31/1.661d-27  
  qe=replicate(0.,nmax+1,nmax,neb,nte) 
  for ie=0L,neb-1 do begin
     if ie mod 10 eq 0 then print, ie, ' of ',neb-1
     eb=ebarr[ie]
     for ite=0L,nte-1 do begin  
        te=tearr[ite]
        ;; Excitation and Deexcitation
        for n=0,nmax-2 do begin
           en = 13.6d-3*(1.-1./(n+1)^2)
           for m=n+1,nmax-1 do begin
              em=13.6d-3*(1.-1./(m+1)^2)
              de = em-en
              qe[m,n,ie,ite] = 0.0
              qe[n,m,ie,ite] = 0.0
           endfor
        endfor    
        ;; Impact ionization ;; Charge exchange
        for n=0,nmax-1 do begin 
	   if n eq 0 then begin
              de = 13.6d-3/(n+1)^2
              qe[nmax,n,ie,ite]= $
              beam_therm_rate(te,eb,ame,ab,de,$
	                      'eiionization_adas_ground',param=[n+1])
	   endif   
        endfor
     endfor
  endfor

  file='qetable_adas_ground.bin'
  openw, lun, file, /get_lun
  writeu,lun, long(nte)
  writeu,lun, double(dte)
  writeu,lun, long(neb)
  writeu,lun, double(deb) 
  writeu,lun, long(nmax) 
  writeu,lun, double(qe)
  close,lun
  free_lun, lun
  print,'electron table written!'
    
  end
