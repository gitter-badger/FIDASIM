FUNCTION finite_struct, s
    n = N_TAGS(s)
    for i=0,n-1 do begin
        if finite(s.(i)) ne 1 then return, 0
    endfor
    return, 1
END 
        
;+ This file contains the procedure to read SPIRAL fast-ion distribution file
FUNCTION read_spiral,file, time=time, ntotal=ntotal, e_range=e_range, $
                           particle_weight=particle_weight, btipsign=btipsign
    ;+ Reads SPIRAL fast-ion distribution file

    dist_struct = {err:1}

    if not keyword_set(btipsign) then begin
        print,'ERROR: btipsign is not set.'
        goto, GET_OUT
    endif

    if not file_test(file) then begin
        print, 'ERROR: Nonexistent file:', file
        goto, GET_OUT
    endif
    
    if not keyword_set(ntotal) and not keyword_set(particle_weight) then begin
        print, 'WARNING: ntotal is not set. Setting arbitrarily to 1e19'
        ntotal = 1.d19
    endif

    if not keyword_set(time) then begin
        print, 'WARNING: Time is not set for SPIRAL distribution. Setting to 0.0 [s]'
        time = 0.d0
    endif

    openr,unit,file, /get_lun

    ; Read header
    header = strarr(4)
    readf, unit, header

    ; Read in number of particles
    line=''
    readf, unit, line
    npart = long(stregex(line,"[0-9]+",/extract))

    ; make sure its a guiding center distribution
    line = ''
    readf, unit, line
    if stregex(line,"guiding center",/fold_case) eq -1 then begin
        print, "ERROR: not a guiding center distribution"
        goto, GET_OUT
    endif

    ; Skip a line
    line = ''
    readf, unit, line

    ; Read in data
    r = dblarr(npart)
    z = dblarr(npart)
    phi = dblarr(npart)
    energy = dblarr(npart)
    pitch = dblarr(npart)
    cnt = 0L
    for i=0,npart-1 do begin
        s = {r:double(0),phi:double(0),z:double(0),energy:double(0),pitch:double(0)}
        readf,unit,s
        if not finite_struct(s) then begin
            continue
        endif else begin
            r[cnt] = s.r*100
            phi[cnt] = s.phi
            z[cnt] = s.z*100
            energy[cnt] = s.energy
            pitch[cnt] = s.pitch*btipsign ; SPIRAL pitch is defined relative to current
            cnt = cnt+1
        endelse
    endfor
    free_lun, unit

    npart = cnt
    r = r[0:npart-1]
    z = z[0:npart-1]
    phi = phi[0:npart-1]
    energy = energy[0:npart-1]
    pitch = pitch[0:npart-1]
    if not keyword_set(particle_weight) then begin
        weight = replicate(Ntotal/npart, npart)
    endif else begin
        weight = replicate(particle_weight, npart)
    endelse
    orbit_class = replicate(1,npart)

    if not keyword_set(e_range) then begin
        e_range = [min(energy),max(energy)]
    endif

    ww = where(energy ge e_range[0] and energy le e_range[1],nw)
    if nw eq 0 then begin
        print,'ERROR: No particles fall in requested energy range'
        goto, GET_OUT
    endif
    print,'Number of markers: ',npart
    print,'Number of markers in energy range: ',nw

    dist_struct = {type:2,time:time,data_source:file, $
                   nparticle:npart,nclass:1,r:r,z:z,phi:phi,$
                   energy:energy,pitch:pitch,class:orbit_class,$
                   weight:weight}
   
    GET_OUT:
    
    return, dist_struct 
END