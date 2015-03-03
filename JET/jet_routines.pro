;;RENAME TO "DEVICE"_ROUTINES I.E. D3D_ROUTINES AND RENAME FILE ACCORDINGLY
PRO jet_routines,inputs,grid,$     ;;INPUT: INPUTS AND GRID POINTS DO NOT CHANGE
					   nbi,$ 			;;OUTPUT: NEUTRAL BEAM INJECTION INFO STRUCTURE
					   chords,$ 		;;OUTPUT: CHORDS INFO STRUCTURE
					   profiles,$		;;OUTPUT: PROFILES STRUCTURE
					   equil,$			;;OUTPUT: MAGNETIC GRID STRUCTURE
					   err				;;OUTPUT: ERROR STATUS ERR=1 == SOMETHING WENT WRONG


	;;IN THIS SECTION YOU CAN USE WHATEVER ROUTINES
	;;YOU WANT SO LONG AS YOU DEFINE THE OUTPUT STRUCTURES
	;;CONTAIN AT LEAST THE FOLLOWING TAGS

    fidasim_dir = getenv("FIDASIM_DIR")

    ;; Get Plasma Profiles
    restore,fidasim_dir+'JET/kinetic_profiles_84408_48700ms.idl'
    profiles.dene *= 1.0d6 ;;1/m^3

	;; Get Viewing Geometry
	chords={sigma_pi_ratio:[1.0],$	;;RATIO OF SIGMA LINES TO PI LINES  (0 IF NPA)
	nchan:1,$				  		;;NUMBER OF CHANNELS
	chan_id:[0] ,$                  ;;CHANNEL ID (0 FOR FIDA,1 FOR NPA)
	xlos:[335.55],$						;;X POS. OF WHERE CHORD CROSSES MIDPLANE [cm]
	ylos:[-40.93704],$						;;Y POS. OF WHERE CHORD CROSSES MIDPLANE [cm]
	zlos:[23.64986],$						;;Z POS. OF WHERE CHORD CROSSES MIDPLANE [cm]
	xlens:[428.58],$						;;X POS. OF LENS/APERTURE [cm]
	ylens:[-85.06495],$						;;Y POS. OF LENS/APERTURE [cm]
	zlens:[28.0],$						;;Z POS. OF LENS/APERTURE [cm]
	ra:[0.],$				            ;;RADIUS OF APERTURE [cm] (0 IF FIDA)
	rd:[0.],$				            ;;RADIUS OF DETECTOR [cm] (0 IF FIDA)
	h:[0.]}		                        ;;SEPERATION BETWEEN DETECTOR AND APERTURE [cm] (0 IF FIDA)

	;; Get Equilibrium
    equil = jet_equil(inputs,grid,chords)

    ;; Get beam stuff
	einj = 98.779 ;;keV
	pinj = 2.0  ;;MW

	;;GET SPECIES_MIX

    ffracs=0.3121
    hfracs=0.3598
    tfracs=1.0-ffracs-hfracs

	nbi={einj:einj,$				   		;;BEAM INJECTION ENERGY [keV]
		 pinj:pinj,$				   		;;BEAM INJECTION POWER  [MW]
		 full:ffracs,$				   		;;FULL BEAM FRACTION
		 half:hfracs,$				   		;;HALF BEAM FRACTION
		 third:tfracs,$				   		;;THIRD BEAM FRACTION
		 xyz_src:[1478.9,280.44,-174.09],$			   		;;POSITION OF BEAM SOURCE IN MACHINE COORDINATES [cm]
		 xyz_pos:[472.3,-2.5,0.0],$			   		;;BEAM CROSSOVER POINT IN MACHINE COORDINATES [cm]
		 bmwidra:11.97851,$			   		;;HORIZONTAL BEAM WIDTH [cm]
		 bmwidza:11.97851,$			   		;;VERTICAL BEAM WIDTH   [cm]
		 focy:999999.9,$				   		;;HORIZONTAL FOCAL LENGTH [cm]
	     focz:999999.9,$						;;VERTICAL FOCAL LENGTH [cm]
		 divy:dblarr(3),$				   		;;HORIZONTAL BEAM DIVERGENCE [rad]
		 divz:dblarr(3) }				   		;;VERTICAL BEAM DIVERGENCE [rad]


END
