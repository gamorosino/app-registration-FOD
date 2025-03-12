#! /bin/bash

# Define the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"

# Input arguments
moving=$1              # Path to the image in moving space
fixed=$2               # Path to the image in fixed space
affine2=$3             # Second affine transformation matrix
warp=$4                # Nonlinear warp field (optional)
output_mif=$5          # Output file (MRtrix format)
inverse=$6             # Flag to indicate type of inverse transform (0, 1, or 2)
affine1=$7             # First affine transformation matrix (optional pre-affine)

# Check that at least the mandatory arguments are provided
if [ $# -lt 4 ]; then
    echo  "usage: "$( basename $0 )" <moving_space.ext> <fixed_space.ext>  <affine.mat> [<warp.ext>] [<output_file.ext>] [<inverse>] [<pre_affine.mat>]"
    exit 1;
fi

# Generate a temporary working directory with a unique name
script_name=$( basename ${0} )
script_name=${script_name:-3}
temp_dir=${SCRIPT_DIR}/tmp/${script_name}$( date +%s)_${RANDOM}/
mkdir -p ${temp_dir}

# Initialize identity warp fields (x, y, z) for transformation
warpinit ${moving} ${temp_dir}/identity_warp[].nii -force

# If no warp is provided, proceed with affine transform only
if ( [ "${warp}" == "None" ] || [ -z ${warp} ] ); then
	echo "apply affine only"
else
	appl_warp=" -t ${warp} "   # Prepare warp transform flag
fi

# Default inverse flag to 0 if not specified
[ -z ${inverse} ] && { inverse=0; }

# -------------------------------------------------------------
# Forward transformation
# -------------------------------------------------------------
if [ $inverse -eq 1 ]; then
	# Apply pre-affine transform if provided
	[ -z ${affine1} ] || { pre_affine=" [-t ${affine1},0]  " ; }
	# Apply main affine transform if provided
	[ "${affine2}" == "None" ] || { apply_affine="-t [${affine2},1] "; }

	# Apply transforms separately on x, y, z warp components
	for i in {0..2}; do
	    antsApplyTransforms -d 3 -e 0 -i ${temp_dir}/identity_warp${i}.nii \
					  -o ${temp_dir}/mrtrix_warp${i}.nii \
					  -r ${fixed} \
					  ${pre_affine} \
					  ${apply_affine} \
					  ${appl_warp}   # optional: --default-value 2147483647
	done

# -------------------------------------------------------------
# Inverse transformation: first method
# -------------------------------------------------------------
elif [ $inverse -eq 0 ]; then
	# Pre-affine (note: reversed transform direction)
	[ -z ${affine1} ] || { pre_affine=" -t [${affine1},0]   " ; }
	# Main affine with inversion
	[ "${affine2}" == "None" ] || { apply_affine="-t [${affine2},0]"  ;}

	# Apply reverse transformation on identity warp fields
	for i in {0..2}; do
		antsApplyTransforms -d 3 -e 0 -i ${temp_dir}identity_warp${i}.nii \
					      -o ${temp_dir}/mrtrix_warp${i}.nii \
					      -r ${moving_space} \
					      ${appl_warp} \
					      ${apply_affine} \
					      ${pre_affine} #--default-value 2147483647
	done

# -------------------------------------------------------------
# Inverse transformation: alternative order
# -------------------------------------------------------------
elif [ $inverse -eq 2 ]; then
	# Apply affine2 and affine1 in alternate order for inverse
	[ "${affine2}" == "None" ] || { apply_affine="-t [${affine2},1]"  ;}
	[ -z ${affine1} ] || { pre_affine=" -t [ ${affine1},1]  " ; }

	for i in {0..2}; do
		antsApplyTransforms -d 3 -e 0 -i ${temp_dir}identity_warp${i}.nii \
					      -o ${temp_dir}/mrtrix_warp${i}.nii \
					      -r ${fixed} \
					      ${appl_warp} \
					      ${apply_affine} \
					      ${pre_affine}
	done
fi

# -------------------------------------------------------------
# Final steps: warp correction and transformation application
# -------------------------------------------------------------

# Correct and merge the three individual warp components into a single vector field
warpcorrect ${temp_dir}/mrtrix_warp[].nii ${temp_dir}/mrtrix_warp_corrected.mif -force # -marker 2147483647

# Apply the final transformation warp to the moving image
mrtransform ${moving} ${output_mif} -warp ${temp_dir}/mrtrix_warp_corrected.mif -reorient_fod yes -force ;

# Clean up temporary directory
[ -d ${temp_dir} ] && { rm -rf ${temp_dir}; }
