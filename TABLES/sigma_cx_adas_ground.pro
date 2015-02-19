;; charge exchange n and m resolved charge exchange cross-sections
;; H(+)+H(n)-->H(m)+H(+)
FUNCTION sigma_cx_adas_ground,erel,n,m

sigma=replicate(0.d,n_elements(erel))

if n eq 1 and (m eq -1 or m eq 1) then begin
  dir='/p/transpusers/mgorelen/transp/adas/tables/cx/
  table_name='cx_1_1_coldTarget.cdf'
  read_adas_tables,table_name,out,dir=dir
  sigma=interpol(out.sigv,out.erel,erel)/ $
	     (sqrt(2.0*1.602e-19*erel*1000./1.66e-27))*1.e4;cm^2
endif

return,sigma

end
