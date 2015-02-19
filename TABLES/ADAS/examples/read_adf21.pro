;----------------------------------------------------------------------
;+
; PROJECT    :  ADAS
;
; NAME       :  read_adf21
;
; PURPOSE    :  Reads adf21 and adf22 (BMS, BME and BMP) files from
;               the IDL command line.
;               called from IDL using the syntax
;               read_adf21,file=...,energy=...,te=... etc
;
; ARGUMENTS  :  All output arguments will be defined appropriately.
;
;               NAME      I/O    TYPE   DETAILS
; REQUIRED   :  files      I     str()  full name of ADAS adf21 files
;               fraction   I     real() target ion fractions; same as number of
;                                       adf21 files
;                                         1st Dimension: requested parameters
;                                         2nd Dimension: numfiles
;                                       If only one dimesnion is present
;                                       read_adf21 assumes that the target
;                                       impurity fraction is the same for all
;                                       requested parameters.
;               te         I     real() temperatures requested (eV)
;               dens       I     real() electron densities requested (cm-3)
;               energy     I     real() beam energies requested (eV/amu)
;
; OPTIONAL      data       O      -     BMS/BME/BMP data (cm3 s-1 / ph cm3 s-1 / na)
;               fulldata   O      -     structure containing all the
;                                       data in the adf21 file. If
;                                       requested other options are
;                                       not used. Note only one file
;                                       is permitted for this option.
;
;                                        file   :  filename
;                                        itz    : target ion charge.
;                                        tsym   : target ion element symbol.
;                                        beref  : reference beam energy (eV/amu).
;                                        tdref  : reference target density (cm-3).
;                                        ttref  : reference target temperature (eV).
;                                        svref  : stopping coefft. at reference
;                                                 beam energy, target density and
;                                                 temperature (cm3 s-1).
;                                        be     : beam energies(eV/amu).
;                                        tdens  : target densities(cm-3).
;                                        ttemp  : target temperatures (eV).
;                                        svt    : stopping coefft. at reference beam
;                                                 energy and target density (cm3 s-1)
;                                        sved   : stopping coefft. at reference target
;                                                 temperature (cm3 s-1).
;
;
; KEYWORDS      help       I      -     prints help to screen
;               nocheck           -     No check will be performed on the
;                                       inputs.
;
;
; NOTES      :  This is part of a chain of programs - read_adf21.c and
;               readadf21.for are required.
;               The BMP variant stores the fractional population of
;               excited beam n-levels and therefore is dimensionless.
;
; AUTHOR     :  Martin O'Mullane
;
; DATE       :  31-05-2000
;
;       1.1     Martin O'Mullane
;                 - First version.
;       1.2     Martin O'Mullane
;                 - No limit on number of energy/Te/dens returned.
;       1.3     Martin O'Mullane/Lorne Horton
;                 - Add fulldata output structure.
;                 - Add a /help keyword.
;                 - Add a /nocheck keyword.
;                 - Increase dimensionality of fraction.
;       1.4     Martin O'Mullane
;                 - The nocheck keyword could not be set as it
;                   was missing from the parameter list.
;       1.5     Martin O'Mullane
;                 - Restrict size of fulldata arrays to amount
;                   of data in adf file.
;                 - Clarify meaning of the input variable, fraction. It
;                   refers to impurity target make-up and not beam energy
;                   full, half and third energy fractions.
;       1.6     Martin O'Mullane
;                 - Extend /nocheck to switch off most on-screen warnings.
;       1.7     Martin O'Mullane
;                 - Use different internal variables for te, dens and energy
;                   leaving their type unchanged after calling the routine.
;
; VERSION    :
;       1.1    31-05-2000
;       1.2    14-05-2003
;       1.3    03-12-2004
;       1.4    03-03-2005
;       1.5    01-05-2009
;       1.6    03-08-2009
;       1.7    16-11-2009
;-
;----------------------------------------------------------------------

PRO read_adf21, files    = files,    $
                energy   = energy,   $
                te       = te,       $
                dens     = dens,     $
                fraction = fraction, $
                data     = data,     $
                fulldata = fulldata, $
                nocheck  = nocheck,  $
                help     = help


; If asked for help

if keyword_set(help) then begin
   doc_library, 'read_adf21'
   return
endif


; Check that we get all inputs and that they are correct. Otherwise print
; a message and return to command line

on_error, 2



; Valid file names and fractions

if n_elements(files) eq 0 then message, 'At least one file name must be passed'
num_files = n_elements(files)

; Make the file checking optional - can be slow on certain systems.
; If /NOCHECK is set, the user must thus guarantee that the
; input files exist and are readable or the fortran will STOP.

if NOT keyword_set(nocheck) then begin

   for j = 0, num_files-1 do begin
      file_acc, files[j], exist, read, write, execute, filetype
      if exist ne 1 then message, 'BMS/BME/BMP file does not exist '+files[j]
      if read ne 1 then message, 'BMS/BME/BMP  file cannot be read from this userid '+files[j]
   endfor

endif


; Either return everything or proceed to extract the requested quantities

if arg_present(fulldata) then begin

   mxbe = 25L
   mxtd = 25L
   mxtt = 25L

   if num_files GT 1 then message, 'Only one file allowed for this option'

   xxdata_21, files[0], mxbe, mxtd, mxtt, itz,    $
              beref, tdref, ttref, svref, nbe,    $
              be, ntdens, tdens, nttemp, ttemp,   $
              svt, sved,  tsym

   fulldata = { file    :  files[0],                  $
                itz     :  itz,                       $
                tsym    :  tsym,                      $
                beref   :  beref,                     $
                tdref   :  tdref,                     $
                ttref   :  ttref,                     $
                svref   :  svref,                     $
                be      :  be[0:nbe-1],               $
                tdens   :  tdens[0:ntdens-1],         $
                ttemp   :  ttemp[0:nttemp-1],         $
                svt     :  svt[0:nttemp-1],           $
                sved    :  sved[0:nbe-1, 0:ntdens-1]  }


endif else begin

   if NOT keyword_set(nocheck) then begin

      if n_elements(fraction) eq 0 then message, 'User requested fractions are missing'

      partype=size(fraction, /type)
      if (partype LT 2) OR (partype GT 5) then $
          message, 'Beam fractions must be numeric'

      ; Check temperature, density and energies

      if n_elements(te) eq 0 then message, 'User requested temperatures are missing'

      partype=size(te, /type)
      if (partype lt 2) or (partype gt 5) then begin
         message,'Temperature must be numeric'
      endif  else te_int = DOUBLE(te)

      if n_elements(dens) eq 0 then message, 'User requested electron densities are missing'

      partype=size(dens, /type)
      if (partype lt 2) or (partype gt 5) then begin
         message,'Electron densities must be numeric'
      endif  else dens_int = DOUBLE(dens)

      if n_elements(energy) eq 0 then message, 'User requested beam energies are missing'

      partype=size(energy, /type)
      if (partype lt 2) or (partype gt 5) then begin
         message,'Beam energies must be numeric'
      endif  else energy_int = DOUBLE(energy)

   endif else begin

      te_int     = double(te)
      dens_int   = double(dens)
      energy_int = double(energy)

   endelse


   ; Set variables for call to C/fortran reading of data
   ; Are te, dens and energy the same length and one dimensional?
   ; if so define data array

   len_te   = n_elements(te_int)
   len_dens = n_elements(dens_int)
   len_eng  = n_elements(energy_int)

   if (len_dens ne len_te) or (len_te ne len_eng) then $
      print, 'TE/DENS/ENERGY size mismatch - smallest  used'

   itval = min([len_te,len_dens,len_eng])


   itval  = LONG(itval)
   data   = DBLARR(itval)

   te_int     = te_int[0:itval-1]
   dens_int   = dens_int[0:itval-1]
   energy_int = energy_int[0:itval-1]


   ; fraction can either be a numeric vector or a 2D array to allow varying
   ; ion fractions along the request vector. If it is a vector expand to a
   ; 2D array keeping the fraction constant.

   res = size(fraction)

   if res[0] GT 2 then begin
      message, 'Only 1 or 2 dimensions allowed for fraction'
   endif else begin
      fraction_use = fraction
      if res[0] EQ 1 then begin
         if NOT keyword_set(nocheck) then message, 'Assume fraction is constant for all requested parameters', /continue
         fraction_use = rebin(reform(fraction, 1, num_files), itval, num_files)
      endif
      fraction_use = double(fraction_use)
   endelse


   ; Pass file names as bytes

   str_vars = strarr(num_files)
   for j = 0, num_files-1 do begin
      str = string(replicate(32B, 132))
      strput, str, files[j], 0
      str_vars[j] = str
   endfor
   str_vars = byte(str_vars)
   str_vars = long(str_vars)


   fortdir = getenv('ADASFORT')


   ; Get data in blocks of MAXVAL to avoid altering cxbms for large sets.

   data = 0.0D0

   MAXVAL = 1024L

   n_call = numlines(itval, MAXVAL)

   for j = 0, n_call - 1 do begin

     ist = j*MAXVAL
     ifn = min([(j+1)*MAXVAL,itval])-1

     t_ca     = te_int[ist:ifn]
     d_ca     = dens_int[ist:ifn]
     e_ca     = energy_int[ist:ifn]
     data_ca  = dblarr(ifn-ist+1)
     itval_ca = ifn-ist+1
     frac_ca  = fraction_use[ist:ifn, *]

     dummy = 0
     dummy = CALL_EXTERNAL(fortdir+'/read_adf21.so','read_adf21',  $
                           num_files, str_vars, frac_ca,           $
                           itval_ca, t_ca, d_ca, e_ca, data_ca)

     data = [data, data_ca]

   endfor
   data = data[1:*]

endelse


END
