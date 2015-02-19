FUNCTION sigmav_piionization_adas_ground,Ti_keV_amu,eb_keV_amu,n

sigma=replicate(0.d,n_elements(eb_keV_amu),n_elements(Ti_keV_amu))

if n eq 1 then begin
  dir='ADAS/adas/tables/ii/
  table_name='ii_1_1_warmTarget.cdf'
  read_adas_tables,table_name,out,dir=dir
  xx=fltarr(n_elements(out.erel)*n_elements(out.tarr))
  yy=fltarr(n_elements(out.erel)*n_elements(out.tarr))
  for i=0,n_elements(out.erel)-1 do begin
      for j=0,n_elements(out.tarr)-1 do begin
	  index=i+j*n_elements(out.erel)
	  xx[index]=out.erel[i]
	  yy[index]=out.tarr[j]
      endfor
  endfor
  TRIANGULATE, xx,yy, tr
  we=where(eb_keV_amu ge min(out.erel) and eb_keV_amu le max(out.erel)  )
  wt=where(Ti_keV_amu ge min(out.tarr) and Ti_keV_amu le max(out.tarr)  )
  for i=0,n_elements(wt)-1 do begin
  sigv=griddata(xx,yy,out.sigv,$
		xout=eb_keV_amu[we],$
                yout=replicate(Ti_keV_amu[wt[i]],n_elements(we)),$
  	        /linear,triangles=tr)*1.e6;cm^3/s

  endfor			 
endif

return,sigv

end
