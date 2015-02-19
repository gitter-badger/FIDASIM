;; Plot ADAS D-alpha charge exchange effective emission coefficient
PRO ADAS_DEMO_DALPHA

  file = '/c/ADAS/adas/adf12/ionatom/ionatom_qeff#h.dat'
  block=1  
  ;; block 3,4 are 2s and 2p donors, respectively for 3-2 transiiton
  file2s = '/c/ADAS/adas/adf12/ionatom/ionatom_qeff#h.dat'
  block2s=3
  file2p = '/c/ADAS/adas/adf12/ionatom/ionatom_qeff#h.dat'
  block2p=4

  file93 = '/c/ADAS/adas/adf12/qef93#h/qef93#h_h1.dat'
  block93 = 2
;  file = '/c/ADAS/adas/adf12/qef97#h/qef97#h_en2_kvi#h1.dat'  ;;  doesn't exist


  ;; Physical parameters
  ai = 2.0 ;; amu
  ab = 2.0

  Zi = 1.0
  Zb = 1.0
  
  bmag = 2.0 ;; T

  einj = 81.0 ;; kV
  ein = (einj*1.e3) / ab ;; eV/amu

  tion = 1.0e3 ;; eV
  
  dion = 1.e13 ;; cm**-3
  
  zeff = 1.0 ;; sum(ni Zi^2)/ne

  READ_ADF12,FILE=file,$
    BLOCK=block,$
    EIN=ein,$
    DION=dion,$
    TION=tion,$
    ZEFF=zeff,$
    BMAG=bmag,$
    ;; Optional Arguments
    TTAR=tion,$
    r_mass=ai,$
    d_mass=ab,$
    /ENERGY,$
    DATA=ADASemission,$ ;; effective emission coeff. ph-cm^3
    WLNGTH=wavelen


    print,ADASemission
    print,wavelen
  
  ;; ----------------------
  ;; Now perform some scans
  ;; ----------------------
  einj_min = 0.0 & einj_max=81.0e3
  einj = FINDGEN(101)*(einj_max-einj_min)/100. + einj_min
  ein = einj/ab ;; eV/amu

  tion_min = 0.0 & tion_max=20.0e3 ;; eV
  tion = FINDGEN(101)*(tion_max-tion_min)/100. + tion_min

  dion_min = 0.5e13 & dion_max=10.0e13 ;; cm**-3
  dion = FINDGEN(101)*(dion_max-dion_min)/100. + dion_min

  zeff_min = 1.0 & zeff_max=6.0 ;; cm**-3
  zeff = FINDGEN(101)*(zeff_max-zeff_min)/100. + zeff_min

  ein_ref = 81.0e3/ab ;; eV/amu
  tion_ref = 4.0e3 ;; eV
  dion_ref = 4.0e13 ;; cm**-3
  zeff_ref = 2.0

  ;; Energy Scan
  READ_ADF12,FILE=file,BLOCK=block,EIN=ein,DION=dion_ref,TION=tion_ref,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff_ein,WLNGTH=wavelen
  READ_ADF12,FILE=file93,BLOCK=block93,EIN=ein,DION=dion_ref,TION=tion_ref,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff93_ein,WLNGTH=wavelen
  ;; Ti Scan
  READ_ADF12,FILE=file,BLOCK=block,EIN=ein_ref,DION=dion_ref,TION=tion,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff_tion,WLNGTH=wavelen
  ;; ni Scan
  READ_ADF12,FILE=file,BLOCK=block,EIN=ein_ref,DION=dion,TION=tion_ref,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff_dion,WLNGTH=wavelen
  ;; Zeff Scan
  READ_ADF12,FILE=file,BLOCK=block,EIN=ein_ref,DION=dion_ref,TION=tion_ref,$
    ZEFF=zeff,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff_zeff,WLNGTH=wavelen

  ;; 2s
  ;; Energy Scan
  READ_ADF12,FILE=file2s,BLOCK=block2s,EIN=ein,DION=dion_ref,TION=tion_ref,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2s_ein,WLNGTH=wavelen
  ;; Ti Scan
  READ_ADF12,FILE=file2s,BLOCK=block2s,EIN=ein_ref,DION=dion_ref,TION=tion,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2s_tion,WLNGTH=wavelen
  ;; ni Scan
  READ_ADF12,FILE=file2s,BLOCK=block2s,EIN=ein_ref,DION=dion,TION=tion_ref,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2s_dion,WLNGTH=wavelen
  ;; Zeff Scan
  READ_ADF12,FILE=file2s,BLOCK=block2s,EIN=ein_ref,DION=dion_ref,TION=tion_ref,$
    ZEFF=zeff,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2s_zeff,WLNGTH=wavelen

  ;; 2p
  ;; Energy Scan
  READ_ADF12,FILE=file2p,BLOCK=block2p,EIN=ein,DION=dion_ref,TION=tion_ref,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2p_ein,WLNGTH=wavelen
  ;; Ti Scan
  READ_ADF12,FILE=file2p,BLOCK=block2p,EIN=ein_ref,DION=dion_ref,TION=tion,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2p_tion,WLNGTH=wavelen
  ;; ni Scan
  READ_ADF12,FILE=file2p,BLOCK=block2p,EIN=ein_ref,DION=dion,TION=tion_ref,$
    ZEFF=zeff_ref,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2p_dion,WLNGTH=wavelen
  ;; Zeff Scan
  READ_ADF12,FILE=file2p,BLOCK=block2p,EIN=ein_ref,DION=dion_ref,TION=tion_ref,$
    ZEFF=zeff,BMAG=bmag,TTAR=tion_ref,r_mass=ai,d_mass=ab,/ENERGY,DATA=qeff2p_zeff,WLNGTH=wavelen

  analytic = analytic_dalpha_rate_coeff(ein*1.e-3) ;; 10^15 ph m^3/s or 10^9 cm

  BAG_PLOT_SETUP,/DIR,XSIZE=1000,YSIZE=800
  !P.MULTI=[0,4,3] & !P.CHARSIZE=3.0
  !Y.TITLE='q(n=1) (10!U-9!N ph-cm!U3!N/s'
  !Y.STYLE=16
  PLOT,ein*1.e-3,qeff_ein*1.e9,XTITLE='E (keV/amu)'
  OPLOTSYM,ein*1.e-3,qeff93_ein*1.e9,/UNIFORM
  oplot,ein*1.e-3,analytic,line=2
  bag_annotate,['ionatom','++93','--von H'],/TOP_LEFT,charsize=1.0
  PLOT,tion*1.e-3,qeff_tion*1.e9,XTITLE='Ti (keV)'
  PLOT,dion*1.e-13,qeff_dion*1.e9,XTITLE='n!DD!N (10!U13!N cm!U-3!N)'
  PLOT,zeff,qeff_zeff*1.e9,XTITLE='Z!Deff!N'

  !Y.TITLE='q(nl=2s) (10!U-9!N ph-cm!U3!N/s'
  PLOT,ein*1.e-3,qeff2s_ein*1.e9,XTITLE='E (keV/amu)'
  PLOT,tion*1.e-3,qeff2s_tion*1.e9,XTITLE='Ti (keV)'
  PLOT,dion*1.e-13,qeff2s_dion*1.e9,XTITLE='n!DD!N (10!U13!N cm!U-3!N)'
  PLOT,zeff,qeff2s_zeff*1.e9,XTITLE='Z!Deff!N'

  !Y.TITLE='q(nl=2p) (10!U-9!N ph-cm!U3!N/s'
  PLOT,ein*1.e-3,qeff2p_ein*1.e9,XTITLE='E (keV/amu)'
  PLOT,tion*1.e-3,qeff2p_tion*1.e9,XTITLE='Ti (keV)'
  PLOT,dion*1.e-13,qeff2p_dion*1.e9,XTITLE='n!DD!N (10!U13!N cm!U-3!N)'
  PLOT,zeff,qeff2p_zeff*1.e9,XTITLE='Z!Deff!N'

END
