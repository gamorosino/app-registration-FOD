# FOD Registration (app-registration-FOD)

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Registers a subject's FA map to a fixed FA image (for example a template) with ANTs (translation, rigid, affine or SyN) and applies the transform to the CSD fibre orientation distributions with MRtrix3 FOD-aware reorientation.**

Runs antsRegistration between the moving and fixed FA maps with a configurable transformation type and pyramid depth, then warps the FOD image of the selected lmax with the MRtrix3 chain warpinit, antsApplyTransforms, warpcorrect and mrtransform so the FODs are reoriented correctly. Use it to bring CSD FODs of a subject into another subject's or a template space, for example for population FOD analyses or template-space tractography. Only the FOD of the chosen lmax is transformed.

| | |
|---|---|
| 📥 **Inputs** | `neuro/csd` · `neuro/tensor` ×2 |
| 📤 **Outputs** | `neuro/csd` · `neuro/transform/nifti` |
| 🐳 **Container** | `brainlife/ants:2.2.0-1bc` |
| ⚙️ **Resources** | 1 CPUs · 2 h walltime |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.849](https://doi.org/10.25663/brainlife.app.849) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `moving-csd` | `neuro/csd` | yes | Moving FODs data. Must contain the FOD for the selected lmax. |
| `moving-tensor` | `neuro/tensor` | yes | Moving DTI Scalars Maps |
| `fixed-tensor` | `neuro/tensor` | yes | Fixed DTI Scalars Maps |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `transformed` | `neuro/csd` | FOD image of the selected lmax resampled and reoriented into the fixed FA space. |
| `transformations` | `neuro/transform/nifti` | ANTs affine (affine.txt) and, for nonlinear registration, warp.nii.gz and inverse-warp.nii.gz. |

<details>
<summary><b>⚙️ Parameters</b> (3)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `lmax` | number | `4` | Select the appropriate value of lmax to be used. |
| `settings` | number | `4` | The `settings` parameter controls the depth of the multiresolution (pyramidal) registration strategy used by ANTs. Higher settings correspond to more levels in the registration pyramid, starting from coarse alignment and progressively refining toward finer spatial correspondence. |
| `transformation` | enum | `rigid` | Choose the type of registration from the following: 1) translation 2) rigid 3) affine 4) nonlinear (diffeomorphic SyN) Options: `translation`, `rigid`, `affine`, `nonlinear`. |

</details>

<!-- brainlife-app:end -->

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
| `lmax`      | Spherical harmonic order of FOD (e.g., `8`)                             |
| `lmax<lmax>`     | FOD image for the selected `lmax` (e.g., `lmax8`)            |
| `fa`        | FA image to register (moving image)                          |
| `fa_fixed`  | Reference FA image (fixed image)                              |
| `settings`  | Registration complexity level (1–4, see table below)         |

---
## Registration Settings

The `settings` parameter controls the depth of the multiresolution (pyramidal) registration strategy used by ANTs. Higher settings correspond to more levels in the registration pyramid, starting from coarse alignment and progressively refining toward finer spatial correspondence.

| Value | Description                    | Pyramid Levels                                  |  Iterations (Linear)              | Iterations (SyN)                | Shrink Factors (Resolution Downsampling) |
|-------|--------------------------------|--------------------------------------------------|---------------------------|-------------------------------|-------------------------------------------|
| 1     | Coarse, single-level registration | 1-level (coarse only)                          | `10000x0x0`              | `100x0x0`                 | `4x2x1`                                   |
| 2     | Coarse-to-medium registration     | 2-level pyramid                                | `10000x10000x0`          | `100x100x0`           | `4x2x1`                                   |
| 3     | Coarse-to-fine registration       | 3-level pyramid                                | `10000x111110x11110`     | `100x100x30`          | `4x2x1`                                   |
| 4     | Full multiresolution registration | 4-level pyramid (coarse → fine)                | `10000x10000x10000`      | `100x80x50x20`       | `8x4x2x1`                                 |


### Notes:
- **Iterations** specify the number of optimization steps per level.
- **Syn Parameters** define the parameters for the Symmetric Normalization (SyN) transformation model.
- **Shrink Factors** determine the level of image resolution downsampling at each pyramid level (from coarse to fine). For example, `8x4x2x1` means:
  - Level 1: image downsampled by 8
  - Level 2: downsampled by 4
  - Level 3: downsampled by 2
  - Level 4: full resolution

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
git clone https://github.com/gamorosino/app-registration-FOD.git
cd app-registration-FOD
```

### 2. Prepare your configuration

Edit the `config.json` file to point to your FA, template FA, FOD, and desired settings level.

### 3. Run the pipeline

```bash
./main
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

1. Locate the `app-registration-FOD` app on Brainlife.
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
