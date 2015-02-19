PRO read_adas_tables,table_name,out,dir=dir,$
    doplot=doplot,xrange=xrange,yrange=yrange,xlog=xlog,ylog=ylog

;dir='/p/transpusers/mgorelen/transp/adas/tables/cx' 
;table_name='cx_1_1_coldTarget.cdf'
;table_name='cx_1_1_warmTarget.cdf'

if keyword_set(dir) then begin
  if strmid(dir,strlen(dir)-1,strlen(dir)-1) ne '/' then dir=dir+'/'
  table_name=dir+table_name 
endif

table=read_ncdf(table_name)
tags=tag_names(table)
;print,tags
w=where(tags eq 'AXIS_PARAM_COLDTARGET')
if w[0] ne -1 then begin
  axis_par=table.AXIS_PARAM_COLDTARGET
  ;print,axis_par
  emin=axis_par[0]
  emax=axis_par[1]
  nerel=axis_par[2]
  linear=axis_par[3] ;0: log, 1: linear
  if linear eq 0 then begin
     erel=emin*exp(lindgen(nerel)/float(nerel-1.)*alog(emax/emin))
  endif else begin
     erel=emin+findgen(nerel)/float(nerel-1.)*(emax-emin)
  endelse
  sigv=table.sigv
  out={erel:erel,sigv:sigv};erel:keV/amu, sigv: m^3/s
endif

w=where(tags eq 'AXIS_PARAM_WARMTARGET')
if w[0] ne -1 then begin
  axis_par=table.AXIS_PARAM_WARMTARGET
  ;print,axis_par
  emin=axis_par[0]
  emax=axis_par[1]
  nerel=axis_par[2]
  linear=axis_par[3] ;0: log, 1: linear   
  if linear eq 0 then begin
     erel=emin*exp(lindgen(nerel)/(nerel-1.)*alog(emax/emin))
  endif else begin
     erel=emin+findgen(nerel)/float(nerel-1.)*(emax-emin)
  endelse
  tmin=axis_par[4]
  tmax=axis_par[5]
  nt=axis_par[6]
  linear=axis_par[7] ;0: log, 1: linear   
  if linear eq 0 then begin
     tarr=tmin*exp(lindgen(nt)/float(nt-1.)*alog(tmax/tmin))
  endif else begin
     tarr=tmin+findgen(nt)/float(nt-1.)*(tmax-tmin)
  endelse
  sigv=table.btsigv
  out={erel:erel,tarr:tarr,sigv:sigv};erel:keV/amu, T: keV/amu, sigv: m^3/s
endif

if keyword_set(doplot) then begin
  loadct,39,/silent,bottom=1; rainbow+white
  n_colors=256
  c = { black : 	0,  $
        blue :   	.25*n_colors, $
        ltblue : 	.40*n_colors, $
        green : 	.65*n_colors, $
        yellow : 	.75*n_colors, $
        orange : 	.80*n_colors, $
        red :    	.90*n_colors, $
        white : 	 n_colors-1   }
    
  !p.background=c.white
  !p.color=c.black

  if !D.Name ne 'PS' then window,/free
  !p.multi=[0,0,0,0,0]
  
  w=where(tags eq 'AXIS_PARAM_COLDTARGET')
  if w[0] ne -1 then begin

    if n_elements(xrange) ne 2 then xrange=[emin,emax]
    w=where(erel ge emin and erel le emax)
    if n_elements(yrange) ne 2 then yrange=[0.9*min(sigv[w]),max(sigv[w])*1.1]
    plot,erel,sigv,$
         xrange=xrange,/xstyle,yrange=yrange,/ystyle,$
         xlog=xlog,ylog=ylog,$
         xtitle='!6E!lrel!n/A [keV/Amu]',ytitle='!6sigma*v [m!u3!n/sec]'  
  endif
  
  w=where(tags eq 'AXIS_PARAM_WARMTARGET')
  if w[0] ne -1 then begin  
    if n_elements(xrange) ne 2 then xrange=[emin,emax]  
    if n_elements(yrange) ne 2 then yrange=[tmin,tmax]  
    if n_elements(zrange) ne 2 then zrange=[0.9*min(sigv),max(sigv)*1.1]
    nlevels=60
    levels=zrange[0]+(zrange[1]-zrange[0])*lindgen(nlevels+1)/float(nlevels)
    contour_bar,sigv,erel,tarr,/fill,levels=levels, xlog=xlog,ylog=ylog,$
            xrange=xrange,/xstyle,yrange=yrange,/ystyle,$ 
            title=title,xtitle=xtitle
  endif

endif
end
