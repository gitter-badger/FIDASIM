;Calculates linear neutral density of beam as it propagates through
;plasma. Also calculates associated beam emission.
;
;Inputs:
;	sh - shot #
;	tw - vector of times of interest
;	bm - FIDA beam ('ss' or 'sw')
;	
;Output:
;	bvolt - voltage of full, half and third energy components at tw/V 
;	rpro - vector of radii at which beam densities are returned
;	lindens - beam neutral density/m^{-1}. 3*n(rpro)*n(tw) array
;		of densities at full, half and third injection energy
;	bmemiss - beam emission/(ph/s/m^1) at rpro at tw for full,
;		half and third injection energies
;	bmsf/h/t - beam stopping coefficients/(cm^3 s^{-1}) at rpro at tw
;	nepro - electron density/m^3 at rpro at tw
;	tepro - electron temperature/eV at rpro at tw
;
;Dependencies: bminit.pro, pathmap function

function pathmap,rpro	;Maps radial locations to positions along bm path
	rtan = make_array(n_elements(rpro),value=0.70)
	zeta = sqrt(rpro^2 - rtan^2)
	return,zeta
end

pro bmlindens,sh,tw,bm,bvolt,rpro,lindens,bmemiss,bmsf,bmsh,bmst,nepro,tepro

;Initialise density of beam according to beam voltage and full, half and
;third beam power:
bminit,sh,tw,bm,bvolt,ninit

dum = getdata('efm_r(psi100)_out',sh)	;Determine outermost radius at
itefm = value_locate(dum.time,tw)		;which plasma exists
rlcfs = max(dum.data(itefm))
rlcfs = make_array(50,value=rlcfs)

rpro = findgen(50)*(rlcfs-0.7)/49. + 0.7	;Array of radii at which
rpro = reverse(rpro)						;to perform calculations
zeta = pathmap(rpro)

plasma,sh,tw,rpro,nepro,tepro	;Get plasma electron density and temp.
default,fracval,1.0	;Default 100% deuterium
frac = make_array(n_elements(bvolt[0,*]),2,value=fracval)

;Files for beam stopping and beam emission of H beam on H ions:
bmsfile = '/home/adas/adas/adf21/bms98#h/bms98#h_h1.dat'
bmefile = '/home/adas/adas/adf22/bme98#h/bme98#h_h1.dat'

lindens = rebin(reform(ninit,3,1,n_elements(tw)),$
		3,n_elements(rpro),n_elements(tw))
bmemiss = lindens

;Beam neutral velocity:
vbeam = 2.998e8*sqrt(2*bvolt/(2.014*9.31494e8))
bmsf = fltarr(n_elements(rpro)-1,n_elements(tw))
bmsh = bmsf
bmst = bmsf

;Loop over radii. For each radius, read in beam stopping coefficient and
;update beam neutral density. Density at step m+1 is given by density at
;step m with an exponential decay determined by local electron (i.e. ion)
;density and local beam stopping coefficient. Beam emission at step m+1
;is given by the product of local neutral and electron densities, and the
;locally-determined beam emission coefficient.
for m=0,n_elements(rpro)-2 do begin
	read_adf21,files=bmsfile,data=sbefull,fraction=frac,$
		te=reform(tepro[m,*]),dens=reform(nepro[m,*])/1e6,$
		energy=reform(bvolt[0,*]),nocheck=nocheck
	read_adf21,files=bmsfile,data=sbehalf,fraction=frac,$
		te=reform(tepro[m,*]),dens=reform(nepro[m,*])/1e6,$
		energy=reform(bvolt[1,*]),nocheck=nocheck
	read_adf21,files=bmsfile,data=sbethird,fraction=frac,$
		te=reform(tepro[m,*]),dens=reform(nepro[m,*])/1e6,$
		energy=reform(bvolt[2,*]),nocheck=nocheck

	bmsf[m,*] = sbefull
	bmsh[m,*] = sbehalf
	bmst[m,*] = sbethird
	
	read_adf22,files=bmefile,data=beefull,fraction=frac,$
		te=reform(tepro[m,*]),dens=reform(nepro[m,*])/1e6,$
		energy=reform(bvolt[0,*]),nocheck=nocheck
	read_adf22,files=bmefile,data=beehalf,fraction=frac,$
		te=reform(tepro[m,*]),dens=reform(nepro[m,*])/1e6,$
		energy=reform(bvolt[1,*]),nocheck=nocheck
	read_adf22,files=bmefile,data=beethird,fraction=frac,$
		te=reform(tepro[m,*]),dens=reform(nepro[m,*])/1e6,$
		energy=reform(bvolt[2,*]),nocheck=nocheck

	lindens[0,m+1,*] = lindens[0,m,*]*$
				exp((sbefull*(reform(nepro[m,*])/1e6)*$
				(zeta[m+1]-zeta[m]))/vbeam[0,*])
	lindens[1,m+1,*] = lindens[1,m,*]*$
				exp((sbehalf*(reform(nepro[m,*])/1e6)*$
				(zeta[m+1]-zeta[m]))/vbeam[1,*])
	lindens[2,m+1,*] = lindens[2,m,*]*$
				exp((sbethird*(reform(nepro[m,*])/1e6)*$
				(zeta[m+1]-zeta[m]))/vbeam[2,*])

	bmemiss[0,m,*] = lindens[0,m,*]*beefull*reform(nepro[m,*])/1e6
	bmemiss[1,m,*] = lindens[1,m,*]*beehalf*reform(nepro[m,*])/1e6
	bmemiss[2,m,*] = lindens[2,m,*]*beethird*reform(nepro[m,*])/1e6
endfor

end
