;; This is a program to view the output from an effective beam
;; emission coefficient ADF22 file read over scanned parameters.
;;
;; Summary: One can produce beam stopping and excited level population
;; files by running the code RUN_ADAS310.  310 requires input files
;; ADF18 and ADF01 for bundle-n expansion file (computed from
;; 701->704) and cross-section for charge-exchange, respectively.
;; 
;; When ADAS310 is run, it produces two files ADF21 and ADF26 which
;; are stopping coefficients and excited level populations,
;; respectively.  The ADF26 (excited leves) file can then be used by
;; ADAS312 to turn the level populations into effective beam emission
;; coefficients by scanning over plasma parameters, producing an ADF22
;; file.
;;
;; My original usage of ADF22 files comes from Mike van Zeeland and
;; the beam emission intensity codes which used the ADF22 files
;;   adasfiles = [ '/c/ADAS/adas/adf22/bme97#h/bme97#h_h1.dat', $
;;                '/c/ADAS/adas/adf22/bme97#h/bme97#h_c6.dat' ]
;; As far as I can tell the beam emission file for h_h1.dat came from
;; the ADF26 file /c/ADAS/adas/adf26/bdn97#h/bdn97#h_h1.dat, and the
;; _c6.dat file came from the similar h_c6.dat file in the same
;; directory.
;;
;; To investigate this, I have now run RUN_ADAS312 on
;; /c/ADAS/adas/adf26/bdn97#h/bdn97#h_h1.dat
;; and produces the output of the similar name to the orignal in my
;; directory /u/grierson/adas/adf22/bme97#h_h1.dat using the commands
;; IDL>adf26='/c/ADAS/adas/adf26/bdn97#h/bdn97#h_h1.dat'
;; IDL>adf22='/u/grierson/adas/adf22/bme97#h_h1.dat'
;; IDL>run_adas312,ADF26=adf26,OUTFILE=adf22,NLOW=2,NUP=3
;; IDL>ADAS_VIEW_ADF22,[adf22,'/c/ADAS/adas/adf22/bme97#h/bme97#h_c6.dat']
;; The results are identical.  I am using RUN_ADAS312 correctly.
;; Now for carbon
;; IDL>adf26c='/c/ADAS/adas/adf26/bdn97#h/bdn97#h_c6.dat'
;; IDL>adf22c='/u/grierson/adas/adf22/bme97#h_c6.dat'
;; IDL>run_adas312,ADF26=adf26c,OUTFILE=adf22c,NLOW=2,NUP=3
;; IDL>ADAS_VIEW_ADF22,[adf22,adf22c]
;; Once again identical to the original files in the ADAS area.
;; My puzzle is trying to figure out how I'm messing up the
;; RUN_ADAS310 calls to produce such a bizarre ADF26 file, which is
;; totally different than the ADF26 file in the /c/ADAS/ area.
;;
;;
;;
;;
;; This code is designed to graphically display the effective emission
;; coefficients from a given set of ADF22 files for excitation due to
;; hydrogenic ions and impurity ions (H and C).
PRO ADAS_VIEW_ADF22,adasfiles,$
                    FRACTION=fraction,$
                    TE=te,$
                    DENS=dens,$
                    ENERGY=energy
  
  IF N_PARAMS() EQ 0 THEN BEGIN
      adasfiles = [ '/c/ADAS/adas/adf22/bme97#h/bme97#h_h1.dat', $
                    '/c/ADAS/adas/adf22/bme97#h/bme97#h_c6.dat' ]
      adasfiles = [ '/u/grierson/adas/delabie/bes_adas310_h1_h_n3_n2.dat', $
                    '/c/ADAS/adas/adf22/bme97#h/bme97#h_c6.dat' ]
  ENDIF

  ;; Fraction of main-ion and impurity ion, i.e. [0.99, 0.01]
  ;; Same order as file.
  IF N_ELEMENTS(fraction) EQ 0 THEN BEGIN
      minfrac=0.001 ;; 0.1 % Carbon
      maxfrac=0.1 ;; 10 % carbon
      nfrac=21
      fraction=FLTARR(2,nfrac) ;; one pair is fraction[*,i]
      FOR i=0,nfrac-1 DO BEGIN
          frac=i*(maxfrac-minfrac)/(nfrac-1)+ minfrac
          fraction[*,i] = [1.-frac,frac] ;; H+ and C+6
      ENDFOR
  ENDIF

  IF N_ELEMENTS(te) EQ 0 THEN BEGIN
      minte=0.1e3 ;; eV
      maxte=10.e3 ;; eV
      nte=21
      te=FLTARR(nte)
      FOR i=0,nte-1 DO te[i]=i*(maxte-minte)/(nte-1) + minte
  ENDIF

  IF N_ELEMENTS(dens) EQ 0 THEN BEGIN
      mindens=0.1e13 ;; cm**-3
      maxdens=10.e13
      ndens=21
      dens=FLTARR(ndens)
      FOR i=0,ndens-1 DO dens[i]=i*(maxdens-mindens)/(ndens-1) + mindens
  ENDIF

  IF N_ELEMENTS(energy) EQ 0 THEN BEGIN
      minenergy=(55.e3) / 2. / 3. ;; Third energy of 55 keV deuterium beam (eV/amu)
      maxenergy=(160.e3) / 2.      ;; Full  energy of 160 keV deuterium beam (eV/amu)
      nenergy=21 
      energy=FLTARR(nenergy)
      FOR i=0,nenergy-1 DO energy[i]=i*(maxenergy-minenergy)/(nenergy-1) + minenergy
  ENDIF

  READ_ADF22,FILES=adasfiles[0],FULLDATA=fulldata
  PRINT,'File: '+STRTRIM(fulldata.file)
  PRINT,'Target ion charge: '+STRTRIM(fulldata.itz,2)
  PRINT,'Target ion element: '+fulldata.tsym
  PRINT,'Reference beam energy: '+STRTRIM(fulldata.beref,2)+' eV/amu'
  PRINT,'Reference target density (cm**-3) ',fulldata.tdref
  PRINT,'Reference target temperature (eV) ',fulldata.ttref
  PRINT,'Beam energies (eV/amu): '+STRTRIM(MIN(fulldata.be),2)+$
    ' - '+STRTRIM(MAX(fulldata.be),2)
  PRINT,'Target Densities (cm**-3): '+STRTRIM(MIN(fulldata.tdens),2)+$
    ' - '+STRTRIM(MAX(fulldata.tdens),2)
  PRINT,'Target Temperatures (eV): '+STRTRIM(MIN(fulldata.ttemp),2)+$
    ' - '+STRTRIM(MAX(fulldata.ttemp),2)

  IF N_ELEMENTS(adasfiles) GT 1 THEN BEGIN
      READ_ADF22,FILES=adasfiles[1],FULLDATA=fulldataC
      PRINT,'File: '+STRTRIM(fulldataC.file)
      PRINT,'Target ion charge: '+STRTRIM(fulldataC.itz,2)
      PRINT,'Target ion element: '+fulldataC.tsym
      PRINT,'Reference beam energy: '+STRTRIM(fulldataC.beref,2)+' eV/amu'
      PRINT,'Reference target density (cm**-3) ',fulldataC.tdref
      PRINT,'Reference target temperature (eV) ',fulldataC.ttref
      PRINT,'Beam energies (eV/amu): '+STRTRIM(MIN(fulldataC.be),2)+' - '+$
        STRTRIM(MAX(fulldataC.be),2)
      PRINT,'Target Densities (cm**-3): '+STRTRIM(MIN(fulldataC.tdens),2)+$
        ' - '+STRTRIM(MAX(fulldataC.tdens),2)
      PRINT,'Target Temperatures (eV): '+STRTRIM(MIN(fulldataC.ttemp),2)+$
        ' - '+STRTRIM(MAX(fulldataC.ttemp),2)
  ENDIF

  ;; There are four variables
  CLEANPLOT,/SILENT
  TEK_COLOR & !P.BACKGROUND=1 & !P.COLOR=0
  WINDOW,/FREE,XSIZE=1000,YSIZE=700
  !P.MULTI=[0,2,2]
  !P.CHARSIZE=1.5
;  !X.STYLE=1 & !Y.STYLE=1
  IF N_ELEMENTS(SIZE(fraction,/DIM)) GT 1 THEN BEGIN
      coeffs=FLTARR((SIZE(fraction,/DIM))[1])
      FOR i=0,(SIZE(fraction,/DIM))[1] -1 DO BEGIN
          frac=fraction[*,i]
          READ_ADF22,FILES=adasfiles,ENERGY=fulldata.beref,TE=fulldata.ttref,$
            DENS=fulldata.tdref,FRACTION=frac,DATA=coeff
          coeffs[i]=coeff
      ENDFOR
      PLOT,REFORM(fraction[1,*]),coeffs*1.e9,$
        TITLE='BE Coeff.',XTITLE='Impurity Fraction',YTITLE='q!UBES!N (10!U-9!N cm!U3!N/s)'
      XYOUTS,!X.CRANGE[0]+0.1*(!X.CRANGE[1]-!X.CRANGE[0]),$
        !Y.CRANGE[1]-0.10*(!Y.CRANGE[1]-!Y.CRANGE[0]),$
        'BE='+STRTRIM(fulldata.beref,2)+'(eV/amu)',CHARSIZE=1.5
      XYOUTS,!X.CRANGE[0]+0.1*(!X.CRANGE[1]-!X.CRANGE[0]),$
        !Y.CRANGE[1]-0.15*(!Y.CRANGE[1]-!Y.CRANGE[0]),$
        'TE='+STRTRIM(fulldata.ttref,2)+'(eV)',CHARSIZE=1.5
      XYOUTS,!X.CRANGE[0]+0.1*(!X.CRANGE[1]-!X.CRANGE[0]),$
        !Y.CRANGE[1]-0.20*(!Y.CRANGE[1]-!Y.CRANGE[0]),$
        'DENS='+STRTRIM(fulldata.tdref,2)+'(cm!U-3!N)',CHARSIZE=1.5
  ENDIF

  ;; Now set the fraction to 1.0 if we've only got one species, or
  ;; [1.0, 0.0, 0.0, ...] if we have more than one.
  frac=FLTARR(N_ELEMENTS(adasfiles)) & frac[0]=1.
  coeffs=FLTARR(ndens)
  FOR i=0,ndens-1 DO BEGIN
      READ_ADF22,FILES=adasfiles,ENERGY=fulldata.beref[0],TE=fulldata.ttref[0],$
        DENS=dens[i],FRACTION=frac,DATA=coeff
      coeffs[i]=coeff
  ENDFOR
  PLOT,dens*1.e-13,coeffs*1.e9,$
    TITLE='BE Coeff.',XTITLE='Density (10!U13!N cm!U-3!N)',YTITLE='q!UBES!N (10!U-9!N cm!U3!N/s)'
  OPLOT,REPLICATE(fulldata.tdref*1.e-13,2),!Y.CRANGE,LINE=2

  coeffs=FLTARR(nte)
  FOR i=0,nte-1 DO BEGIN
      READ_ADF22,FILES=adasfiles,ENERGY=fulldata.beref,TE=te[i],$
        DENS=fulldata.tdref,FRACTION=frac,DATA=coeff
      coeffs[i]=coeff
  ENDFOR
  PLOT,te*1.e-3,coeffs*1.e9,$
    TITLE='BE Coeff.',XTITLE='Te (keV)',YTITLE='q!UBES!N (10!U-9!N cm!U3!N/s)'
  OPLOT,REPLICATE(fulldata.ttref*1.e-3,2),!Y.CRANGE,LINE=2

  coeffs=FLTARR(nenergy)
  FOR i=0,nenergy-1 DO BEGIN
      READ_ADF22,FILES=adasfiles,ENERGY=energy[i],TE=fulldata.ttref,$
        DENS=fulldata.tdref,FRACTION=frac,DATA=coeff
      coeffs[i]=coeff
  ENDFOR
  PLOT,energy*1.e-3,coeffs*1.e9,$
    TITLE='BE Coeff.',XTITLE='Energy (keV / amu)',YTITLE='q!UBES!N (10!U-9!N cm!U3!N/s)'
  OPLOT,REPLICATE(fulldata.beref*1.e-3,2),!Y.CRANGE,LINE=2


END
