;; ELECTRON IMPACT IONIZATION
FUNCTION eiionization_adas_ground,ecoll_keV,nint

if nint eq 1 then begin
   dir='ADAS/adas/tables/ei/'
   table_name='ei_1_coldTarget.cdf'

   read_adas_tables,table_name,out,dir=dir
   sigv=interpol(out.sigv,out.erel,ecoll_keV) ;m^3/s
   w=where(sigv lt 0.0)
   if w[0] ne -1 then sigv[w]=0
endif else sigv=ecoll_keV*0.0

mass_u=1.6605d-27
am = 9.109d-31/1.6605d-27
ab=2.0
ared = am*ab/(am+ab)
u=sqrt(2.0*1.602e-19*ecoll_keV*1000./(ared*mass_u)) ;m/s
;vel=sqrt(2.0*1.602e-19*ecoll_keV*1000./9.109e-31); m/s
   
return,sigv/u*1.d4;cm^2

end
