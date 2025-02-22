#!/bin/bash

# generates staining intensity profiles given a volume and matched surface files

#---------------- FUNCTION: HELP ----------------#
help() {
echo -e "
\033[38;5;141mCOMMAND:\033[0m
   $(basename "$0")
\033[38;5;141mREQUIRED ARGUMENTS:\033[0m
\t\033[38;5;197m-in_vol\033[0m 	      		: input volume to be sampled. Must be .mnc
\t\033[38;5;197m-upper_surf\033[0m 	      	: upper surface. Must be aligned to the volume and an .obj
\t\033[38;5;197m-lower_surf\033[0m              : lower surface. Must be aligned to the volume and an .obj
\t\033[38;5;197m-num_surf\033[0m              	: number of surfaces to generate
\t\033[38;5;197m-wd\033[0m 	              	: Path to a working directory, where data will be output
\t

Requirements:
minc, numpy

Example:
sh sample_intensity_profiles.sh -in_vol full8_1000um_optbal.mnc -upper_surf tpl-bigbrain_hemi-L_desc-pial.obj -lower_surf tpl-bigbrain_hemi-L_desc-white.obj -num_surf 50 -wd Output

Output:
profiles.txt - microstructure profiles
*.obj 	- equivolumetric surfaces, numbered by depth
*.txt	- intensities per surface, numbered by depth

Casey Paquola, MNI, MICA Lab, 2021
https://bigbrainwarp.readthedocs.io/
"
}

# Create VARIABLES
for arg in "$@"
do
  case "$arg" in
  -h|-help)
    help
    exit 1
  ;;
  --in_vol)
    in_vol=$2
    shift;shift
  ;;
  --wd)
    wd=$2
    shift;shift
  ;;
  --upper_surf)
    upper_surf=$2
    shift;shift
  ;;
  --lower_surf)
    lower_surf=$2
    shift;shift
  ;;
  --num_surf)
    num_surf=$2
    shift;shift
  ;;
  -*)
    echo "Unknown option ${2}"
    help
    exit 1
  ;;
    esac
done

# pull surface tools repo, if not already contained in scripts
if [[ ! -d "$bbwDir"/scripts/surface_tools/ ]] ; then
	cd "$bbwDir"/scripts/
	git clone https://github.com/kwagstyl/surface_tools
fi
cd "$bbwDir"/scripts/surface_tools/equivolumetric_surfaces/

# generate intracortical surfaces
python generate_equivolumetric_surfaces.py "$upper_surf" "$lower_surf" "$num_surf" "$wd"
x=$(ls -t "$wd"*.obj) # order surfaces by time created
for n in $(seq 1 1 "$num_surf") ; do
	echo "$n"
	which_surf=$(sed -n "$n"p <<< "$x")
	# make numbering from upper to lower
	let "nd = "$num_surf" - "$n""
	volume_object_evaluate "$in_vol" "$which_surf" "$wd"/"$nd".txt # samples volume intensities based on coordinates in the intracortical surfaces
done

cd "$bbwDir"/scripts/
python compile_profiles.py "$wd" "$num_surf" # organises the output in a nice, simple table
