# app-apply-ants-transform

This repository provides a reproducible pipeline to apply spatial transformations to diffusion MRI data using [ANTs (Advanced Normalization Tools)](http://stnava.github.io/ANTs/) and [MRtrix3](https://www.mrtrix.org/), both executed in Singularity containers for reproducibility and platform independence.

The workflow performs nonlinear registration between FA images using ANTs, and applies the resulting warp and affine transformations to FOD images in a way compatible with MRtrix3.

## Features

This pipeline performs:
- Nonlinear registration of FA images using ANTs
- Application of the resulting transformations to FOD data using `warpinit → antsApplyTransforms → warpcorrect → mrtransform`
- All transformations and tools are executed via Singularity containers
- Clean, modular design with FOD transformation handled in a dedicated helper script

### Author

    Gabriele Amorosino (gabriele.amorosino@utexas.edu)

---

## Inputs

All parameters are provided via a `config.json` file.

### Example `config.json`:
```json
{
    "lmax": 8,
    "fa": "input/fa.nii.gz",
    "fa_fixed": "template/fa_template.nii.gz",
    "lmax8": "input/lmax8.mif",
    "settings": "3"
}
```

### Field Descriptions

| Field       | Description                                                  |
|-------------|--------------------------------------------------------------|
| `lmax`      | Spherical harmonic order of FOD                              |
| `lmaxX`     | FOD image for the selected `lmax` (e.g., `lmax8`)            |
| `fa`        | FA image to register (moving image)                          |
| `fa_fixed`  | Template FA image (fixed image)                              |
| `settings`  | Registration complexity level (1–4, see table below)         |

---

## Registration Settings

| Value | Description             | Parameters                                          |
|-------|-------------------------|-----------------------------------------------------|
| 1     | One-level registration  | Affine: `10000x0x0`, Syn: `100x0x0,0,5`                      |
| 2     | Two-level registration  | Affine: `10000x10000x0`, Syn: `100x100x0,-0.01,5`           |
| 3     | Three-level registration| Affine: `10000x111110x11110`, Syn: `100x100x30,-0.01,5`     |
| 4     | Four-level registration | Affine: `10000x10000x10000`, Syn: `100x80x50x20,-0.01,10`   |

---

## Output

The output of this app is the FOD image after transformation. It is saved at:

```bash
transformed/<basename_of_fod_input>
```
and the transformations

```bash
transformations/
warp.nii.gz
inverse-warp.nii.gz 
affine.txt 
```

---

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/gamorosino/app-align-FOD.git
cd app-align-FOD
```

### 2. Prepare your configuration

Edit the `config.json` file to point to your FA, template FA, FOD, and desired settings level.

### 3. Run the pipeline

```bash
./apply_transform_main_final.sh
```

This will:
- Run ANTs registration
- Apply the estimated warp and affine to the FOD image using MRtrix3
- Save the transformed FOD image to the `transformed/` folder

---

## Requirements

- **Singularity** (used to run both ANTs and MRtrix3 containers)
- **jq** (for parsing `config.json`)

---

## Usage on Brainlife.io

This app is structured for deployment on [Brainlife.io](https://brainlife.io/).

### Web UI

1. Locate the `app-apply-ants-transform` app on Brainlife.
2. Execute the pipeline via the graphical interface.

### CLI

```bash
bl login
bl app run --id <app_id> \
           --project <project_id> \
           --input fa:<fa_object> fa_fixed:<template_object> fod:<fod_object> ...
```

---

## Citation

If you use this app, please cite:

- **ANTs**: Avants et al., *NeuroImage* (2011)  
  https://doi.org/10.1016/j.neuroimage.2010.09.025

- **MRtrix3**: Tournier et al., *NeuroImage* (2019)  
  https://doi.org/10.1016/j.neuroimage.2019.116137

- **Brainlife.io**: Hayashi et al., *Nature Methods* (2024)  
  https://doi.org/10.1038/s41592-024-02237-2

---

## License

MIT License
