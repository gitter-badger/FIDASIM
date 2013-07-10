;;RENAME TO "DEVICE"_ROUTINES I.E. D3D_ROUTINES AND RENAME FILE ACCORDINGLY
PRO d3d_routines,inputs,grid,$ 			;;INPUT: INPUTS AND GRID
					   nbi,$ 			;;OUTPUT: NEUTRAL BEAM INJECTION INFO STRUCTURE
					   fida,$ 			;;OUTPUT: FIDA DIAGNOSTIC INFO STRUCTURE
					   profiles,$		;;OUTPUT: PROFILES STRUCTURE
					   equil,$			;;OUTPUT: MAGNETIC GRID STRUCTURE
					   err				;;OUTPUT: ERROR STATUS ERR=1 == SOMETHING WENT WRONG

	;;GET BEAM GEOMETRY
	nbi=d3d_beams(inputs)
	
	;;GET CHORD GEOMETRY
	fida=d3d_chords(inputs)

	;;GET PROFILES
	profiles=d3d_profiles(inputs)

	;;GET E&M FIELDS AT GRID POINTS
	equil=d3d_equil(inputs,grid)

	err=0	
	GET_OUT:
END 
