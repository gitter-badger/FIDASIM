;;These are instructions to run the input procedure for people who cannot use the JSON input template.

;;-----------------------------------------------------
;;IDL> .compile /path/to/procedure/input_template.pro
;;IDL> prefida,'input_template'  ;; <- input_template is the name of the procedure
;;-----------------------------------------------------

;;This input file is a procedure so name this file accordingly
PRO jet_inputs,inputs                                   ;; Name of this file without .pro

;;-----------------------------------------------------
;;              PREFIDA INPUT FILE
;;-----------------------------------------------------
comment='JET SRS Benchmark'
shot=84408L                                            ;; Shot Number
time=48.7                                              ;; Time
runid='SRS_BENCH'                                       ;; runid of FIDASIM
device='JET'                                            ;; D3D,NSTX,AUGD,MAST
result_dir='/u/stagnerl/FIDA/SRS_BENCH/'           ;; Location where results will be stored /RESULTS/runid will be made
profile_dir='/u/stagnerl/FIDASIM/JET/'                     ;; Location of profile save files. EX: profile_dir+'shot/'+'dne142353.00505'

;;----------------------------------------------------
;; Fast-ion distribution function from transp
;;----------------------------------------------------
cdf_file='/u/stagnerl/FIDASIM/JET/test_dist.cdf'   ;; CDF file from transp with the distribution funciton

emin=0.                                                      ;; Minimum energy used from the distribution function
emax=100.                                                    ;; Maximum energy used from the distribution function
pmin=-1.                                                     ;; Minimum pitch used from the distribution function
pmax=1.                                                      ;; Maximum pitch used from the distribution function

;;-----------------------------------------------------
;; Beam/FIDA/EQUILIBRIUM Selection
;;-----------------------------------------------------
isource=5                                               ;; Beam source index (FIDASIM only simulates on NBI source)
einj=0.                                                 ;; [keV] If 0, get data from MDS+
pinj=0.                                                 ;; [MW] If 0, get data from MDS+

diag='TEST'                                          ;; Name of the FIDA diag
equil=''                                          ;; Name of equilibrium. Ex. for D3D EFIT02

;;-----------------------------------------------------
;; Discharge Parameters
;;-----------------------------------------------------
btipsign=1.d0                                          ;; Bt and Ip are in the opposite direction
ab=2.01410178d0                                         ;; Atomic mass of beam [u]
ai=2.01410178d0                                         ;; Atomic mass of hydrogenic plasma ions [u]
impurity_charge=6                                       ;; 5: BORON, 6: carbon, 7: Nitrogen

;;-----------------------------------------------------
;; Wavelength Grid
;;-----------------------------------------------------
lambdamin=647.d0                                        ;; Minimum wavelength of wavelength grid [nm]
lambdamax=667.d0                                        ;; Maximum wavelength of wavelength grid [nm]
nlambda=2000L                                           ;; Number of wavelengths
dlambda= (lambdamax-lambdamin)/double(nlambda)          ;; Wavelength seperation

;;---------------------------------------------------
;; Define FIDASIM grid in machine coordinates(x,y,z)
;;---------------------------------------------------
nx=60               ;; Number of cells in x direction
ny=40              ;; Number of cells in y direction
nz=50               ;; Number of cells in z direction
xmin=80.         ;; Minimum x value
xmax=200.          ;; Maximum x value
ymin=-40.         ;; Minimum y value
ymax=40.          ;; Maximum y value
zmin=-30.          ;; Minimum z value
zmax=70.           ;; Maximum z value

origin=[472.3,-2.5,0.0];[0.0,0.0,0.0]   ;; If using different a coordinate system, this is the origin
                          ;; in machine coordinates of the new system

alpha=(360-344.3)*!DPI/180.0 -!DPI           ;; Rotation angle in radians from +x about z axis that transforms machine
                    ;; coordinates to the new system.
beta=0.0            ;; Rotation about +y axis
;;--------------------------------------------------
;; Define number of Monte Carlo particles
;;--------------------------------------------------
nr_fast=5000000                                         ;; FIDA
nr_nbi=50000                                            ;; Beam emission
nr_halo=500000                                          ;; Halo contribution

;;--------------------------------------------------
;; Calculation of the weight function
;;--------------------------------------------------
ne_wght=50                                              ;; Number of Energies
np_wght=50                                              ;; Number of Pitches
nphi_wght=50                                            ;; Number of Gyro-angles
emax_wght=125.                                          ;; Maximum energy (keV)
ichan_wght=-1                                           ;; -1 for all channels, otherwise a given channel index
dwav_wght=.2                                            ;; Wavelength interval
wavel_start_wght=651.                                   ;; Minimum wavelength
wavel_end_wght=663.                                     ;; Maximum wavelength

;;-------------------------------------------------
;; Simulation switches
;;-------------------------------------------------
calc_npa=[0]                                            ;; (0 or 1) If 1 do a simulation for NPA
calc_spec=[1]                                           ;; (0 or 1) If 1 then spectra is calculated
calc_birth=[1]                                          ;; (0 or 1) If 1 then the birth profile is calculated
calc_brems=[0]                                          ;; (0 or 1) If 0 use the IDL bremstrahlung calculation
calc_fida_wght=[1]                                      ;; (0 or 1) If 1 then fida weight functions are calculated
calc_npa_wght=[0]                                       ;; (0 or 1) If 1 then npa weight functions are calculated
load_neutrals=[0]                                       ;; (0 or 1) If 1 then the neutral density is loaded from an existing run
load_fbm=[1]                                            ;; (0 or 1) If 1 then the fbm is loaded (calc_spec/npa overwrites)
interactive=[0]                                         ;; (0 or 1) If 1 then percent complete is shown

;;------------------------------------------------
;; DO NOT MODIFY THIS PART
;;------------------------------------------------
install_dir=+GETENV('FIDASIM_DIR')
inputs={comment:comment,shot:shot,time:time,runid:runid,device:strupcase(device),install_dir:install_dir,result_dir:result_dir,$
        cdf_file:cdf_file,profile_dir:profile_dir,emin:emin,emax:emax,pmin:pmin,pmax:pmax,isource:isource,diag:diag,$
        einj:einj,pinj:pinj,equil:equil,btipsign:btipsign,ab:ab,ai:ai,impurity_charge:impurity_charge,$
        lambdamin:lambdamin,lambdamax:lambdamax,nlambda:nlambda,dlambda:dlambda,$
        nx:nx,ny:ny,nz:nz,xmin:xmin,xmax:xmax,ymin:ymin,ymax:ymax,zmin:zmin,zmax:zmax,$
        origin:origin,alpha:alpha,beta:beta,$
        nr_fast:nr_fast,nr_nbi:nr_nbi,nr_halo:nr_halo,ne_wght:ne_wght,np_wght:np_wght,nphi_wght:nphi_wght,$
        emax_wght:emax_wght,ichan_wght:ichan_wght,dwav_wght:dwav_wght,wavel_start_wght:wavel_start_wght,$
        wavel_end_wght:wavel_end_wght,calc_npa:calc_npa,calc_spec:calc_spec,calc_birth:calc_birth,calc_fida_wght:calc_fida_wght,$
        calc_npa_wght:calc_npa_wght,calc_brems:calc_brems,load_neutrals:load_neutrals,load_fbm:load_fbm,interactive:interactive}

END